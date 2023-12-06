use std::fs::File;
use std::io::BufReader;

use data::PostgresTestResult;
use plotly::common::{Mode, Title};
use plotly::layout::{GridDomain, LayoutGrid};
use plotly::{BoxPlot, Layout, Plot, Scatter};
mod data;
fn line_and_scatter_plot() -> Plot {
    let trace1 = Scatter::new(vec![1, 2, 3, 4], vec![10, 15, 13, 17])
        .name("trace1")
        .mode(Mode::Markers);
    let trace2 = Scatter::new(vec![2, 3, 4, 5], vec![16, 5, 11, 9])
        .name("trace2")
        .mode(Mode::Lines);
    let trace3 = Scatter::new(vec![1, 2, 3, 4], vec![12, 9, 15, 12]).name("trace3");

    let mut plot = Plot::new();
    plot.add_trace(trace1);
    plot.add_trace(trace2);
    plot.add_trace(trace3);
    plot
}

fn main() -> color_eyre::Result<()> {
    // RESULTS WITH UNLOCKED RESOURCES
    let host_unlimited_test_path =
        "../code/test_results/host_cluster_postgres_test_2023-11-30T17:31:18.541691.json";
    let vcluster_unlimited_test_path =
        "../code/test_results/vcluster_pgtest_postgres_test_2023-11-30T18:54:43.967308.json";
    let (ul_rw, ul_ro) =
        host_vcluster_postgres_plot(host_unlimited_test_path, vcluster_unlimited_test_path)?;
    // let ro_time = BoxPlot::new(ro_time).name("Read Only Time");
    // ro.add_trace(ro_time);

    ul_rw.write_image(
        "images/postgres/unlimited/rw.svg",
        plotly::ImageFormat::SVG,
        800,
        600,
        1.0,
    );
    ul_ro.write_image(
        "images/postgres/unlimited/ro.svg",
        plotly::ImageFormat::SVG,
        800,
        600,
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
        800,
        600,
        1.0,
    );

    lim_ro.write_image(
        "images/postgres/limited/ro.svg",
        plotly::ImageFormat::SVG,
        800,
        600,
        1.0,
    );

    let host_only_pgbench = single_pgbench_rw_plot(host_unlimited_test_path)?;
    host_only_pgbench.write_image(
        "images/postgres/unlimited/host_only_rw.svg",
        plotly::ImageFormat::SVG,
        800,
        600,
        1.0,
    );

    let host_only_pgbench_ro = single_pgbench_ro_plot(host_unlimited_test_path)?;
    host_only_pgbench_ro.write_image(
        "images/postgres/unlimited/host_only_ro.svg",
        plotly::ImageFormat::SVG,
        800,
        600,
        1.0,
    );
    // println!("{:#?}", data);
    // line_and_scatter_plot().write_image("images/demo.svg", plotly::ImageFormat::SVG, 800, 600, 1.0);
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
    let rw_layout =
        Layout::new().title(Title::new("Read Write performance with unlocked resources"));
    rw.set_layout(rw_layout);

    let host_rw_tps = host_data
        .read_write
        .values()
        .map(|x| x.tps)
        .collect::<Vec<f64>>();

    let host_rw_tps = BoxPlot::new(host_rw_tps).name("Host TPS");
    let vcluster_rw_tps = vcluster_data
        .read_write
        .values()
        .map(|x| x.tps)
        .collect::<Vec<f64>>();
    rw.add_trace(host_rw_tps);
    let vcluster_rw_tps = BoxPlot::new(vcluster_rw_tps).name("Vcluster TPS");
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
    let ro_tps = host_data
        .read_only
        .values()
        .map(|x| x.tps)
        .collect::<Vec<f64>>();
    let vc_ro_tps = vcluster_data
        .read_only
        .values()
        .map(|x| x.tps)
        .collect::<Vec<f64>>();
    let vc_ro_tps = BoxPlot::new(vc_ro_tps).name("Vcluster Read Only TPS");
    let ro_tps = BoxPlot::new(ro_tps).name("Read Only TPS");
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
        .box_points(plotly::box_plot::BoxPoints::All);
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
