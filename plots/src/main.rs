use std::fs::File;
use std::io::BufReader;
use std::path::PathBuf;

use plotly::box_plot::{BoxMean, BoxPoints};
use plotly::common::Title;
use plotly::layout::{Axis, GridDomain, LayoutGrid};
use plotly::{BoxPlot, Layout, Plot};
use rayon::prelude::*;

mod data;
use data::PostgresTestResult;

fn main() -> color_eyre::Result<()> {
    // baseline_graphs()?;
    let pgbench_host_paths = [
        "../code/test_results/pgtest_run_2/host_cluster_postgres_test_10_2023-12-07T15:30:48.276825.json",
        "../code/test_results/pgtest_run_2/host_cluster_postgres_test_20_2023-12-07T16:34:49.250646.json",
        "../code/test_results/pgtest_run_2/host_cluster_postgres_test_50_2023-12-07T18:15:52.635879.json",
        "../code/test_results/pgtest_run_2/host_cluster_postgres_test_100_2023-12-07T21:19:47.730306.json",
        "../code/test_results/pgtest_run_2/host_cluster_postgres_test_200_2023-12-08T04:33:11.296866.json",
    ];
    let pgbench_vcluster_paths = [
        "../code/test_results/pgtest_run_2/vcluster_postgres_test_10_2023-12-08T10:49:21.739420.json",
        "../code/test_results/pgtest_run_2/vcluster_postgres_test_20_2023-12-08T11:56:45.050519.json",
        "../code/test_results/pgtest_run_2/vcluster_postgres_test_50_2023-12-08T13:45:23.802124.json",
        "../code/test_results/pgtest_run_2/vcluster_postgres_test_100_2023-12-08T17:07:10.443653.json",
        "../code/test_results/pgtest_run_2/vcluster_postgres_test_200_2023-12-09T02:01:23.375601.json",
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
                .name("Host")
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
                .y_axis(Axis::new().title(Title::new("Transactions per second")))
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
                1.0,
            );

            let mut ro = Plot::new();
            let ro_layout = Layout::new()
                .y_axis(Axis::new().title(Title::new("Transactions per second")))
                .show_legend(false);
            ro.set_layout(ro_layout);
            let mut host_ro_tps: Vec<f64> =
                host_cluster.read_only.values().map(|x| x.tps).collect();
            host_ro_tps.sort_by(|a, b| a.partial_cmp(b).unwrap());
            // let host_ro_tps = host_ro_tps[1..host_ro_tps.len() - 1].to_vec();
            let host_ro_tps = BoxPlot::new(host_ro_tps)
                .name("Host")
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

    Ok(())
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
        .show_legend(false);
    rw.set_layout(rw_layout);

    let mut host_rw_tps = host_data
        .read_write
        .values()
        .map(|x| x.tps)
        .collect::<Vec<f64>>();
    host_rw_tps.sort_by(|a, b| a.partial_cmp(b).unwrap());
    let host_rw_tps = host_rw_tps[0..host_data.read_write.len() - 1].to_vec();

    let host_rw_tps = BoxPlot::new(host_rw_tps)
        .name("Host")
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
    let host_rw_time = host_data
        .read_write
        .values()
        .map(|x| x.time)
        .collect::<Vec<f64>>();
    let host_rw_time = BoxPlot::new(host_rw_time).name("host Time");
    let vcluser_rw_time = vcluster_data
        .read_write
        .values()
        .map(|x| x.time)
        .collect::<Vec<f64>>();
    let vcluser_rw_time = BoxPlot::new(vcluser_rw_time).name("vcluster Time");
    let mut ro = Plot::new();
    ro.set_layout(Layout::new().show_legend(false));
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
        .name("Host")
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
        .grid(LayoutGrid::new().domain(GridDomain::new().x(vec![90.0, 100.0])));
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
        .box_points(plotly::box_plot::BoxPoints::All)
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
        .box_points(plotly::box_plot::BoxPoints::All);
    host_rw_tps
}
