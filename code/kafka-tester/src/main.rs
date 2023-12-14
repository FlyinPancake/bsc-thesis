use clap::Parser;
use hdrhistogram::Histogram;

use rdkafka::{
    admin::{AdminClient, NewTopic, TopicReplication},
    consumer::{Consumer, StreamConsumer},
    producer::{FutureProducer, FutureRecord},
    ClientConfig, Message,
};
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};
use tracing::info;
use tracing_subscriber::EnvFilter;

#[derive(Debug, Parser)]
struct Cli {
    #[clap(short, long)]
    broker: String,
    #[clap(short, long)]
    topic: String,
    #[clap(short, long, default_value = "10")]
    warmup: u64,
    #[clap(short = 'D', long, default_value = "50")]
    test_duration: u64,
    #[clap(short, long, default_value = "1024")]
    data_size: usize,
    #[clap(short, long, default_value = "1")]
    producers: u64,
    #[clap(short, long, default_value = "1")]
    consumers: u64,
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::Subscriber::builder()
        .with_env_filter(
            EnvFilter::from_default_env().add_directive("kafka_benchmark=trace".parse().unwrap()),
        )
        .init();

    let args = Cli::parse();
    let broker = args.broker;
    let topic = args.topic;

    let admin: AdminClient<_> = ClientConfig::new()
        .set("bootstrap.servers", &broker)
        .create()
        .expect("Admin client creation failed");

    info!("Deleting topic if it exists");
    match admin.delete_topics(&[&topic], &Default::default()).await {
        Ok(_) => {}
        Err(e) => {
            info!("Error deleting topic: {:?}", e);
        }
    }

    info!("Creating topic");
    let new_topic = NewTopic {
        name: &topic,
        num_partitions: 1,
        replication: TopicReplication::Fixed(1),
        config: Default::default(),
    };
    admin
        .create_topics(&[new_topic], &Default::default())
        .await
        .expect("Topic creation failed");

    // produce_messages(&topic, broker);

    let producer: FutureProducer = ClientConfig::new()
        .set("bootstrap.servers", &broker)
        .set("message.timeout.ms", "5000")
        .create()
        .expect("Producer creation error");

    let consumer: StreamConsumer = ClientConfig::new()
        .set("group.id", "test-group")
        .set("bootstrap.servers", &broker)
        .set("enable.partition.eof", "false")
        .set("session.timeout.ms", "6000")
        .set("enable.auto.commit", "false")
        .set("allow.auto.create.topics", "true")
        .create()
        .expect("Consumer creation failed");

    tokio::time::sleep(Duration::from_secs(1)).await;
    consumer
        .subscribe(&[&topic])
        .expect("Can't subscribe to specified topic");
    for _ in 0..args.producers {
        let producer = producer.clone();
        let topic = topic.clone();
        let data_size = args.data_size;
        tokio::spawn(async move {
            let mut i = 0_usize;
            loop {
                let padding = " ".repeat(data_size);
                producer
                    .clone()
                    .send_result(
                        FutureRecord::to(&topic)
                            .key(&format!("Key {}", i))
                            .payload(&padding)
                            .timestamp(now()),
                    )
                    .unwrap()
                    .await
                    .unwrap()
                    .unwrap();
                i += 1;
            }
        });
    }

    let start = Instant::now();
    let mut latencies = Histogram::<u64>::new(5).unwrap();
    tokio::time::sleep(Duration::from_secs(1)).await;
    info!("Warming up for 10 seconds...");
    loop {
        let message = match consumer.recv().await {
            Ok(m) => m,
            Err(_) => continue,
        };
        let then = message.timestamp().to_millis().unwrap();
        if start.elapsed() < Duration::from_secs(10) {
            continue;
        } else if start.elapsed() < Duration::from_secs(60) {
            if latencies.len() == 0 {
                info!("Recording latencies for 50 seconds...");
            }
            latencies += (now() - then) as u64;
        } else {
            break;
        }
    }

    println!("measurements: {}", latencies.len());
    println!("mean latency: {}ms", latencies.mean());
    println!("p50 latency:  {}ms", latencies.value_at_quantile(0.50));
    println!("p90 latency:  {}ms", latencies.value_at_quantile(0.90));
    println!("p99 latency:  {}ms", latencies.value_at_quantile(0.99));
}

fn now() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("Time went backwards")
        .as_millis()
        .try_into()
        .unwrap()
}
