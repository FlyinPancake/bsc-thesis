#!/usr/bin/python3

import argparse
from datetime import datetime
import itertools
import json
import subprocess
from dataclasses import dataclass
from uuid import uuid4


from alive_progress import alive_bar


@dataclass
class KafkaBenchmarkResult:
    measurements: int
    mean_latency: float
    p50_latency: int
    p90_latency: int
    p99_latency: int


def run_kafka_bench(args: list[str]):
    command = ["kafka_benchmark", *args]
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            check=True,
        )
        print(result.stderr.decode("utf-8"))
        return result
    except subprocess.CalledProcessError as e:
        print(e.stderr.decode("utf-8"))
        raise Exception(f"Error running kafka-bench command: {e}")


def kafka_benchmark(
    broker: str,
    topic: str,
    message_size: int = 1024,
    warmup: int = 10,
    test_duration: int = 50,
    producers=1,
    consumers=1,
):
    return run_kafka_bench(
        [
            "--broker",
            broker,
            "--topic",
            topic,
            "--data-size",
            str(message_size),
            "--warmup",
            str(warmup),
            "--test-duration",
            str(test_duration),
            "--producers",
            str(producers),
            "--consumers",
            str(consumers),
        ]
    ).stdout.decode("utf-8")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Run kafka-bench with different parameters"
    )
    parser.add_argument(
        "--broker",
        type=str,
        help="The broker to connect to",
    )
    parser.add_argument(
        "--topic", type=str, help="The topic to use", default=f"{uuid4()}"
    )
    args = parser.parse_args()
    broker = args.broker
    topic = args.topic
    kafka_bench_filename = f"kafka_benchmark_{datetime.now().isoformat()}.json"
    producer_counts = [1, 3, 5]
    consumer_counts = [1, 3, 5]
    message_sizes = [100, 1024]
    bench_params = list(
        itertools.product(producer_counts, consumer_counts, message_sizes)
    )
    test_results = {}
    try:
        with alive_bar(len(bench_params) * 3) as bar:
            for producer_count, consumer_count, message_size in bench_params:
                test_results[
                    f"{producer_count}_{consumer_count}_{message_size}"
                ] = list()
                for i in range(3):
                    bar()
                    print(
                        f"🧪 Running test [{i+1}/3] with {producer_count} producer{'s' if producer_count>1 else ''}, {consumer_count} consumer{'s' if consumer_count>1 else ''}, and message size {message_size}"
                    )
                    start_time = datetime.now()
                    test_result = json.loads(
                        kafka_benchmark(
                            broker=broker,
                            topic=topic,
                            message_size=message_size,
                            producers=producer_count,
                            consumers=consumer_count,
                            warmup=10,
                            test_duration=50,
                        )
                    )
                    print(f"🧪 Test took {datetime.now() - start_time}")
                    test_results[
                        f"{producer_count}_{consumer_count}_{message_size}"
                    ].append(test_result)
    finally:
        with open(kafka_bench_filename, "w") as f:
            json.dump(test_results, f, indent=4)
