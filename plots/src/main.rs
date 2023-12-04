use std::fs::File;
use std::io::BufReader;

use data::PostgresTestResult;
use plotly::common::{Mode, Title};
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
    let host_reader = BufReader::new(File::open(
        "../code/test_results/host_cluster_postgres_test_2023-11-30T17:31:18.541691.json",
    )?);
    let vcluster_reader = BufReader::new(File::open(
        "../code/test_results/vcluster_pgtest_postgres_test_2023-11-30T18:54:43.967308.json",
    )?);

    let host_data: PostgresTestResult = serde_json::from_reader(host_reader)?;
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
    let vcluster_rw_tps = vcluster_data
        .read_write
        .values()
        .map(|x| x.tps)
        .collect::<Vec<f64>>();

    let host_rw_tps = BoxPlot::new(host_rw_tps).name("Host TPS");
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
    // rw.add_trace(host_rw_time);
    // rw.add_trace(vcluser_rw_time);

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
    // let ro_time = BoxPlot::new(ro_time).name("Read Only Time");
    // ro.add_trace(ro_time);

    rw.write_image("images/rw.svg", plotly::ImageFormat::SVG, 800, 600, 1.0);
    ro.write_image("images/ro.svg", plotly::ImageFormat::SVG, 800, 600, 1.0);
    // println!("{:#?}", data);
    // line_and_scatter_plot().write_image("images/demo.svg", plotly::ImageFormat::SVG, 800, 600, 1.0);
    Ok(())
}
