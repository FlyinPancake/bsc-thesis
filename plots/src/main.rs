use plotly::common::Mode;
use plotly::{Plot, Scatter};

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
    line_and_scatter_plot().write_image("images/demo.svg", plotly::ImageFormat::SVG, 800, 600, 1.0);
    Ok(())
}
