use std::collections::HashMap;
use std::fs::File;
use std::io::BufReader;
use std::path::{Path, PathBuf};

use hdrhistogram::Histogram;
use plotly::box_plot::{BoxMean, BoxPoints};
use plotly::common::{Font, Mode, TickMode, Title};
use plotly::layout::{Axis, GridDomain, LayoutGrid, Legend};
use plotly::{BoxPlot, Layout, Plot, Scatter};
use rayon::prelude::*;

mod data;
use data::{KafkaTestResult, PostgresTestResult};

type KafkaTestContainer = HashMap<String, Vec<KafkaTestResult>>;

fn main() -> color_eyre::Result<()> {
    baseline_graphs()?;
    // scaled_tests();

    // kafka_plots();

    let pgbench_host_results = [
        "../code/test_results/pgtest_run_3/host_cluster_postgres_test_10_2023-12-11T16:41:49.374536.json",
        "../code/test_results/pgtest_run_3/host_cluster_postgres_test_20_2023-12-11T17:41:47.794923.json",
        // "../code/test_results/pgtest_run_3/host_cluster_postgres_test_50_2023-12-11T19:09:30.445457.json",
        "../code/test_results/pgtest_run_2/host_cluster_postgres_test_50_2023-12-07T18:15:52.635879.json",
        // "../code/test_results/pgtest_run_3/host_cluster_postgres_test_100_2023-12-11T22:15:51.328719.json",
        "../code/test_results/pgtest_run_2/host_cluster_postgres_test_100_2023-12-07T21:19:47.730306.json",
        // "../code/test_results/pgtest_run_3/host_cluster_postgres_test_200_2023-12-12T07:07:27.622227.json",
        "../code/test_results/pgtest_run_2/host_cluster_postgres_test_200_2023-12-08T04:33:11.296866.json",
    ].iter().map(Path::new).map(
        |p| {
            let reader = BufReader::new(File::open(p).unwrap());
            let data: PostgresTestResult = serde_json::from_reader(reader).unwrap();
            data
        }
    );

    let pgbench_vcluster_results = [
        "../code/test_results/pgtest_run_3/vcluster_postgres_test_10_2023-12-13T12:34:25.632275.json",
        "../code/test_results/pgtest_run_3/vcluster_postgres_test_20_2023-12-13T13:41:31.930968.json",
        "../code/test_results/pgtest_run_3/vcluster_postgres_test_50_2023-12-13T15:34:37.375514.json",
        // "../code/test_results/pgtest_run_2/vcluster_postgres_test_50_2023-12-08T13:45:23.802124.json",
        "../code/test_results/pgtest_run_3/vcluster_postgres_test_100_2023-12-13T19:14:53.252644.json",
        "../code/test_results/pgtest_run_3/vcluster_postgres_test_200_2023-12-14T03:58:19.576822.json",
    ].iter().map(Path::new).map(
        |p| {
            let reader = BufReader::new(File::open(p).unwrap());
            let data: PostgresTestResult = serde_json::from_reader(reader).unwrap();
            data
        }
    );

    let mut plot = Plot::new();
    let pgbench_host_tps_rw_means = pgbench_host_results
        .clone()
        .map(|x| {
            let host_rw_tps_sum: f64 = x.read_write.values().map(|x| x.tps).sum();
            let host_rw_tps_count = x.read_write.len();
            host_rw_tps_sum / host_rw_tps_count as f64
        })
        .collect::<Vec<f64>>();

    let pgbench_vcluster_tps_rw_means = pgbench_vcluster_results
        .clone()
        .map(|x| {
            let host_rw_tps_sum: f64 = x.read_write.values().map(|x| x.tps).sum();
            let host_rw_tps_count = x.read_write.len();
            host_rw_tps_sum / host_rw_tps_count as f64
        })
        .collect::<Vec<f64>>();
    let trace = Scatter::new((0..5).collect(), pgbench_host_tps_rw_means)
        .name("bare-metal")
        .mode(Mode::LinesMarkers);
    plot.add_trace(trace);

    let trace = Scatter::new((0..5).collect(), pgbench_vcluster_tps_rw_means)
        .name("vcluster")
        .mode(Mode::LinesMarkers);
    plot.add_trace(trace);

    plot.set_layout(
        Layout::default()
            .x_axis(
                Axis::new()
                    .title(Title::new("Scaling Factor"))
                    .tick_mode(TickMode::Array)
                    .tick_values(vec![0., 1., 2., 3., 4.])
                    .tick_text(vec!["10", "20", "50", "100", "200"]),
            )
            .y_axis(Axis::new().title(Title::new("Average Transactions per second"))),
    );

    plot.write_image(
        "images/postgres/scales/rw_means.svg",
        plotly::ImageFormat::SVG,
        1100,
        420,
        1.0,
    );

    let mut plot = Plot::new();

    let pgbench_host_tps_ro_means = pgbench_host_results
        .clone()
        .map(|x| {
            let host_rw_tps_sum: f64 = x.read_only.values().map(|x| x.tps).sum();
            let host_rw_tps_count = x.read_only.len();
            host_rw_tps_sum / host_rw_tps_count as f64
        })
        .collect::<Vec<f64>>();

    let pgbench_vcluster_tps_ro_means = pgbench_vcluster_results
        .clone()
        .map(|x| {
            let host_rw_tps_sum: f64 = x.read_only.values().map(|x| x.tps).sum();
            let host_rw_tps_count = x.read_only.len();
            host_rw_tps_sum / host_rw_tps_count as f64
        })
        .collect::<Vec<f64>>();
    let trace = Scatter::new((0..5).collect(), pgbench_host_tps_ro_means)
        .name("bare-metal")
        .mode(Mode::LinesMarkers);
    plot.add_trace(trace);

    let trace = Scatter::new((0..5).collect(), pgbench_vcluster_tps_ro_means)
        .name("vcluster")
        .mode(Mode::LinesMarkers);

    plot.add_trace(trace);

    plot.set_layout(
        Layout::default()
            .x_axis(
                Axis::new()
                    .title(Title::new("Scaling Factor"))
                    .tick_mode(TickMode::Array)
                    .tick_values(vec![0., 1., 2., 3., 4.])
                    .tick_text(vec!["10", "20", "50", "100", "200"]),
            )
            .y_axis(Axis::new().title(Title::new("Average Transactions per second"))),
    );

    plot.write_image(
        "images/postgres/scales/ro_means.svg",
        plotly::ImageFormat::SVG,
        1100,
        420,
        1.0,
    );

    Ok(())
}

fn kafka_plots() {
    let kafka_test_host: KafkaTestContainer = serde_json::from_reader(BufReader::new(
        File::open(Path::new(
            "../code/test_results/kafka_bench/kafka_benchmark_2023-12-15T12:04:48.920760.json",
        ))
        .unwrap(),
    ))
    .unwrap();

    let host_means = kafka_test_host
        .values()
        .flat_map(|x| x.iter().map(|x| x.mean_latency).collect::<Vec<f64>>())
        .collect::<Vec<f64>>();

    let trace = BoxPlot::new(host_means)
        .name("bare-metal")
        // .box_points(BoxPoints::All)
        .box_mean(BoxMean::True);

    let mut plt = Plot::new();
    plt.add_trace(trace);
    let kafka_test_vcluster: KafkaTestContainer = serde_json::from_reader(BufReader::new(
        File::open(Path::new(
            "../code/test_results/kafka_bench/kafka_benchmark_2023-12-15T14:25:22.420148.json",
        ))
        .unwrap(),
    ))
    .unwrap();

    let vcluster_means = kafka_test_vcluster
        .values()
        .flat_map(|x| x.iter().map(|x| x.mean_latency).collect::<Vec<f64>>())
        .collect::<Vec<f64>>();

    let trace = BoxPlot::new(vcluster_means)
        .name("vcluster")
        // .box_points(BoxPoints::All)
        .box_mean(BoxMean::True);
    plt.add_trace(trace);
    let new_layout = plt
        .layout()
        .clone()
        .grid(LayoutGrid::new().domain(GridDomain::new().x(vec![90.0, 100.0])))
        .y_axis(
            Axis::new()
                .title(Title::new("Average Latency (ms)").font(Font::default().size(20)))
                .tick_font(Font::new().size(20)),
        )
        .x_axis(Axis::new().tick_font(Font::new().size(20)))
        .show_legend(false);
    plt.set_layout(new_layout);
    plt.write_image(
        "images/kafka/latency.svg",
        plotly::ImageFormat::SVG,
        1100,
        420,
        1.0,
    );

    let mut plt = Plot::new();
    let host_p90 = kafka_test_host
        .values()
        .flat_map(|x| x.iter().map(|x| x.p90_latency).collect::<Vec<u64>>())
        .collect::<Vec<u64>>();
    let trace = BoxPlot::new(host_p90)
        .name("bare-metal")
        // .box_points(BoxPoints::All)
        .box_mean(BoxMean::True);
    plt.add_trace(trace);
    let vcluster_p90 = kafka_test_vcluster
        .values()
        .flat_map(|x| x.iter().map(|x| x.p90_latency).collect::<Vec<u64>>())
        .collect::<Vec<u64>>();
    let trace = BoxPlot::new(vcluster_p90)
        .name("vcluster")
        // .box_points(BoxPoints::All)
        .box_mean(BoxMean::True);
    plt.add_trace(trace);
    let new_layout = plt
        .layout()
        .clone()
        .grid(LayoutGrid::new().domain(GridDomain::new().x(vec![90.0, 100.0])))
        .y_axis(
            Axis::new()
                .title(Title::new("90th Percentile Latency (ms)").font(Font::default().size(20)))
                .tick_font(Font::new().size(20)),
        )
        .x_axis(Axis::new().tick_font(Font::new().size(20)))
        .show_legend(false);
    plt.set_layout(new_layout);
    plt.write_image(
        "images/kafka/p90.svg",
        plotly::ImageFormat::SVG,
        1100,
        420,
        1.0,
    );

    let mut plt = Plot::new();
    let host_p99 = kafka_test_host
        .values()
        .flat_map(|x| x.iter().map(|x| x.p99_latency).collect::<Vec<u64>>())
        .collect::<Vec<u64>>();
    let trace = BoxPlot::new(host_p99)
        .name("bare-metal")
        // .box_points(BoxPoints::All)
        .box_mean(BoxMean::True);
    plt.add_trace(trace);
    let vcluster_p99 = kafka_test_vcluster
        .values()
        .flat_map(|x| x.iter().map(|x| x.p99_latency).collect::<Vec<u64>>())
        .collect::<Vec<u64>>();
    let trace = BoxPlot::new(vcluster_p99)
        .name("vcluster")
        // .box_points(BoxPoints::All)
        .box_mean(BoxMean::True);
    plt.add_trace(trace);
    let new_layout = plt
        .layout()
        .clone()
        .grid(LayoutGrid::new().domain(GridDomain::new().x(vec![90.0, 100.0])))
        .y_axis(
            Axis::new()
                .title(Title::new("99th Percentile Latency (ms)").font(Font::default().size(20)))
                .tick_font(Font::new().size(20)),
        )
        .x_axis(Axis::new().tick_font(Font::new().size(20)))
        .show_legend(false);
    plt.set_layout(new_layout);
    plt.write_image(
        "images/kafka/p99.svg",
        plotly::ImageFormat::SVG,
        1100,
        420,
        1.0,
    );
}

fn scaled_tests() {
    let pgbench_host_paths = [
        "../code/test_results/pgtest_run_3/host_cluster_postgres_test_10_2023-12-11T16:41:49.374536.json",
        "../code/test_results/pgtest_run_3/host_cluster_postgres_test_20_2023-12-11T17:41:47.794923.json",
        // "../code/test_results/pgtest_run_3/host_cluster_postgres_test_50_2023-12-11T19:09:30.445457.json",
        "../code/test_results/pgtest_run_2/host_cluster_postgres_test_50_2023-12-07T18:15:52.635879.json",
        // "../code/test_results/pgtest_run_3/host_cluster_postgres_test_100_2023-12-11T22:15:51.328719.json",
        "../code/test_results/pgtest_run_2/host_cluster_postgres_test_100_2023-12-07T21:19:47.730306.json",
        // "../code/test_results/pgtest_run_3/host_cluster_postgres_test_200_2023-12-12T07:07:27.622227.json",
        "../code/test_results/pgtest_run_2/host_cluster_postgres_test_200_2023-12-08T04:33:11.296866.json",
    ];
    let pgbench_vcluster_paths = [
        "../code/test_results/pgtest_run_3/vcluster_postgres_test_10_2023-12-13T12:34:25.632275.json",
        "../code/test_results/pgtest_run_3/vcluster_postgres_test_20_2023-12-13T13:41:31.930968.json",
        "../code/test_results/pgtest_run_3/vcluster_postgres_test_50_2023-12-13T15:34:37.375514.json",
        // "../code/test_results/pgtest_run_2/vcluster_postgres_test_50_2023-12-08T13:45:23.802124.json",
        "../code/test_results/pgtest_run_3/vcluster_postgres_test_100_2023-12-13T19:14:53.252644.json",
        "../code/test_results/pgtest_run_3/vcluster_postgres_test_200_2023-12-14T03:58:19.576822.json",
    ];

    let pgbench_host_paths: Vec<PostgresTestResult> = pgbench_host_paths
        .into_par_iter()
        .map(PathBuf::from)
        .map(|pb| {
            let reader = BufReader::new(File::open(pb).unwrap());
            let data: PostgresTestResult = serde_json::from_reader(reader).unwrap();
            data
        })
        .collect();

    let pgbench_vcluster_paths: Vec<PostgresTestResult> = pgbench_vcluster_paths
        .into_par_iter()
        .map(PathBuf::from)
        .map(|pb| {
            let reader = BufReader::new(File::open(pb).unwrap());
            let data: PostgresTestResult = serde_json::from_reader(reader).unwrap();
            data
        })
        .collect();

    pgbench_host_paths
        .into_par_iter()
        .zip(pgbench_vcluster_paths)
        .for_each(|(host_cluster, vcluster)| {
            let mut host_rw_tps: Vec<f64> =
                host_cluster.read_write.values().map(|x| x.tps).collect();
            host_rw_tps.sort_by(|a, b| a.partial_cmp(b).unwrap());
            // let host_rw_tps = host_rw_tps[1..host_rw_tps.len() - 1].to_vec();
            let host_rw_tps = BoxPlot::new(host_rw_tps)
                .name("bare-metal")
                .box_points(BoxPoints::False)
                .box_mean(BoxMean::True);
            let mut vcluster_rw_tps: Vec<f64> =
                vcluster.read_write.values().map(|x| x.tps).collect();
            vcluster_rw_tps.sort_by(|a, b| a.partial_cmp(b).unwrap());
            // let vcluster_rw_tps = vcluster_rw_tps[1..vcluster_rw_tps.len() - 1].to_vec();
            let vcluster_rw_tps = BoxPlot::new(vcluster_rw_tps)
                .name("vcluster")
                .box_points(BoxPoints::False)
                .box_mean(BoxMean::True);
            let mut rw = Plot::new();
            let rw_layout = Layout::new()
                // .title(Title::new("Read Write performance with unlocked resources"))
                .y_axis(
                    Axis::new()
                        .title(Title::new("Transactions per second").font(Font::default().size(20)))
                        .tick_font(Font::new().size(20)),
                )
                .x_axis(Axis::new().tick_font(Font::new().size(20)))
                .show_legend(false);
            rw.set_layout(rw_layout);
            rw.add_trace(host_rw_tps);
            rw.add_trace(vcluster_rw_tps);
            rw.write_image(
                format!(
                    "images/postgres/scales/rw_{}.svg",
                    host_cluster.read_only["0"].scaling_factor
                ),
                plotly::ImageFormat::SVG,
                1100,
                420,
                2.0,
            );

            let mut ro = Plot::new();
            let ro_layout = Layout::new()
                .y_axis(
                    Axis::new()
                        .title(Title::new("Transactions per second").font(Font::default().size(20)))
                        .tick_font(Font::new().size(20)),
                )
                .x_axis(Axis::new().tick_font(Font::new().size(20)))
                .show_legend(false);
            ro.set_layout(ro_layout);
            let mut host_ro_tps: Vec<f64> =
                host_cluster.read_only.values().map(|x| x.tps).collect();
            host_ro_tps.sort_by(|a, b| a.partial_cmp(b).unwrap());
            // let host_ro_tps = host_ro_tps[1..host_ro_tps.len() - 1].to_vec();
            let host_ro_tps = BoxPlot::new(host_ro_tps)
                .name("bare-metal")
                .box_points(BoxPoints::False)
                .box_mean(BoxMean::True);
            let mut vcluster_ro_tps: Vec<f64> =
                vcluster.read_only.values().map(|x| x.tps).collect();
            vcluster_ro_tps.sort_by(|a, b| a.partial_cmp(b).unwrap());
            // let vcluster_ro_tps = vcluster_ro_tps[1..vcluster_ro_tps.len() - 1].to_vec();
            let vcluster_ro_tps = BoxPlot::new(vcluster_ro_tps)
                .name("vcluster")
                .box_points(BoxPoints::False)
                .box_mean(BoxMean::True);
            ro.add_trace(host_ro_tps);
            ro.add_trace(vcluster_ro_tps);
            ro.write_image(
                format!(
                    "images/postgres/scales/ro_{}.svg",
                    host_cluster.read_only["0"].scaling_factor
                ),
                plotly::ImageFormat::SVG,
                1100,
                420,
                1.0,
            );
        });
}

fn baseline_graphs() -> Result<(), color_eyre::eyre::Error> {
    let host_unlimited_test_path =
        "../code/test_results/host_cluster_postgres_test_2023-11-30T17:31:18.541691.json";
    let vcluster_unlimited_test_path =
        "../code/test_results/vcluster_pgtest_postgres_test_2023-11-30T18:54:43.967308.json";
    let (ul_rw, ul_ro) =
        host_vcluster_postgres_plot(host_unlimited_test_path, vcluster_unlimited_test_path)?;
    ul_rw.write_image(
        "images/postgres/unlimited/rw.svg",
        plotly::ImageFormat::SVG,
        1100,
        420,
        1.0,
    );
    ul_ro.write_image(
        "images/postgres/unlimited/ro.svg",
        plotly::ImageFormat::SVG,
        1100,
        420,
        1.0,
    );
    let host_limited_postgres_path =
        "../code/test_results/host_cluster_postgres_test_200_2023-12-05T16:03:01.984713.json";
    let vcluster_limited_postgres_path =
        "../code/test_results/vcluster_postgres_test_200_2023-12-05T14:47:36.817246.json";
    let (lim_rw, lim_ro) =
        host_vcluster_postgres_plot(host_limited_postgres_path, vcluster_limited_postgres_path)?;
    lim_rw.write_image(
        "images/postgres/limited/rw.svg",
        plotly::ImageFormat::SVG,
        1100,
        500,
        1.0,
    );
    lim_ro.write_image(
        "images/postgres/limited/ro.svg",
        plotly::ImageFormat::SVG,
        1100,
        500,
        1.0,
    );
    let host_only_pgbench = single_pgbench_rw_plot(host_unlimited_test_path)?;
    host_only_pgbench.write_image(
        "images/postgres/unlimited/host_only_rw.svg",
        plotly::ImageFormat::SVG,
        400,
        300,
        1.0,
    );
    let host_only_pgbench_ro = single_pgbench_ro_plot(host_unlimited_test_path)?;
    host_only_pgbench_ro.write_image(
        "images/postgres/unlimited/host_only_ro.svg",
        plotly::ImageFormat::SVG,
        400,
        300,
        1.0,
    );
    Ok(())
}

fn host_vcluster_postgres_plot(
    host_unlimited_test_path: &str,
    vcluster_unlimited_test_path: &str,
) -> Result<(Plot, Plot), color_eyre::eyre::Error> {
    let host_reader = BufReader::new(File::open(host_unlimited_test_path)?);
    let host_data: PostgresTestResult = serde_json::from_reader(host_reader)?;
    let vcluster_reader = BufReader::new(File::open(vcluster_unlimited_test_path)?);
    let vcluster_data: PostgresTestResult = serde_json::from_reader(vcluster_reader)?;
    let mut rw = Plot::new();
    let rw_layout = Layout::new()
        // .title(Title::new("Read Write performance with unlocked resources"))
        .show_legend(false)
        .y_axis(
            Axis::new()
                .title(Title::new("Transactions per second").font(Font::default().size(20)))
                .tick_font(Font::new().size(20)),
        )
        .x_axis(Axis::new().tick_font(Font::new().size(20)));
    rw.set_layout(rw_layout);

    let mut host_rw_tps = host_data
        .read_write
        .values()
        .map(|x| x.tps)
        .collect::<Vec<f64>>();
    host_rw_tps.sort_by(|a, b| a.partial_cmp(b).unwrap());
    let host_rw_tps = host_rw_tps[0..host_data.read_write.len() - 1].to_vec();

    let host_rw_tps = BoxPlot::new(host_rw_tps)
        .name("bare-metal")
        .box_points(BoxPoints::False)
        .box_mean(BoxMean::True);
    let mut vcluster_rw_tps = vcluster_data
        .read_write
        .values()
        .map(|x| x.tps)
        .collect::<Vec<f64>>();
    vcluster_rw_tps.sort_by(|a, b| a.partial_cmp(b).unwrap());
    let vcluster_rw_tps = vcluster_rw_tps[1..vcluster_data.read_write.len() - 1].to_vec();
    rw.add_trace(host_rw_tps);
    let vcluster_rw_tps = BoxPlot::new(vcluster_rw_tps)
        .name("vcluster")
        .box_points(BoxPoints::SuspectedOutliers)
        .box_mean(BoxMean::True);
    rw.add_trace(vcluster_rw_tps);

    let mut ro = Plot::new();
    ro.set_layout(
        Layout::new()
            .show_legend(false)
            .y_axis(
                Axis::new()
                    .title(Title::new("Transactions per second").font(Font::default().size(20)))
                    .tick_font(Font::new().size(20)),
            )
            .x_axis(Axis::new().tick_font(Font::new().size(20))),
    );
    let mut ro_tps = host_data
        .read_only
        .values()
        .map(|x| x.tps)
        .collect::<Vec<f64>>();
    ro_tps.sort_by(|a, b| a.partial_cmp(b).unwrap());
    let ro_tps = ro_tps[1..ro_tps.len() - 1].to_vec();
    let mut vc_ro_tps = vcluster_data
        .read_only
        .values()
        .map(|x| x.tps)
        .collect::<Vec<f64>>();
    vc_ro_tps.sort_by(|a, b| a.partial_cmp(b).unwrap());
    let vc_ro_tps = vc_ro_tps[1..vc_ro_tps.len() - 1].to_vec();
    let vc_ro_tps = BoxPlot::new(vc_ro_tps)
        .name("vcluster")
        .box_points(BoxPoints::False)
        .box_mean(BoxMean::True);
    let ro_tps = BoxPlot::new(ro_tps)
        .name("bare-metal")
        .box_mean(BoxMean::True)
        .box_points(BoxPoints::False);
    ro.add_trace(ro_tps);
    ro.add_trace(vc_ro_tps);
    let _ro_time = host_data
        .read_only
        .values()
        .map(|x| x.time)
        .collect::<Vec<f64>>();
    Ok((rw, ro))
}

fn single_pgbench_rw_plot(test_path: &str) -> color_eyre::Result<Plot> {
    let reader = BufReader::new(File::open(test_path)?);
    let host_data: PostgresTestResult = serde_json::from_reader(reader)?;
    let trace = pgbench_rw_box_plot(&host_data, "");

    let mut plt = Plot::new();
    plt.add_trace(trace);
    let new_layout = plt
        .layout()
        .clone()
        .grid(LayoutGrid::new().domain(GridDomain::new().x(vec![90.0, 100.0])))
        .y_axis(Axis::new().title(Title::new("Transactions per second")));
    plt.set_layout(new_layout);
    Ok(plt)
}

fn single_pgbench_ro_plot(test_path: &str) -> color_eyre::Result<Plot> {
    let reader = BufReader::new(File::open(test_path)?);
    let host_data: PostgresTestResult = serde_json::from_reader(reader)?;
    let trace = pgbench_ro_box_plot(&host_data, "");

    let mut plt = Plot::new();
    plt.add_trace(trace);
    let new_layout = plt
        .layout()
        .clone()
        .grid(LayoutGrid::new().domain(GridDomain::new().x(vec![90.0, 100.0])));
    plt.set_layout(new_layout);
    Ok(plt)
}

fn pgbench_rw_box_plot(
    host_data: &PostgresTestResult,
    box_plot_name: &str,
) -> Box<BoxPlot<f64, f64>> {
    let mut host_rw_tps = host_data
        .read_write
        .values()
        .map(|x| x.tps)
        .collect::<Vec<f64>>();
    host_rw_tps.sort_by(|a, b| a.partial_cmp(b).unwrap());
    // remove first and last elements
    let host_rw_tps = host_rw_tps[1..host_rw_tps.len() - 1].to_vec();
    let host_rw_tps = BoxPlot::new(host_rw_tps)
        .name(box_plot_name)
        .box_mean(BoxMean::True);
    host_rw_tps
}

fn pgbench_ro_box_plot(
    host_data: &PostgresTestResult,
    box_plot_name: &str,
) -> Box<BoxPlot<f64, f64>> {
    let mut host_rw_tps = host_data
        .read_only
        .values()
        .map(|x| x.tps)
        .collect::<Vec<f64>>();
    host_rw_tps.sort_by(|a, b| a.partial_cmp(b).unwrap());
    // remove first and last elements
    let host_rw_tps = host_rw_tps[1..host_rw_tps.len() - 1].to_vec();
    let host_rw_tps = BoxPlot::new(host_rw_tps)
        .name(box_plot_name)
        .box_mean(BoxMean::True);
    host_rw_tps
}
