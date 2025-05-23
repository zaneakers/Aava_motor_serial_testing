using PlotlyJS

trace1 = scatter(
    x=[1, 2, 3, 4, 5],
    y=[1, 2, 3, 4, 5],
    name="Increasing",
    showlegend=false
)

trace2 = scatter(
    x=[1, 2, 3, 4, 5],
    y=[5, 4, 3, 2, 1],
    name="Decreasing"
)

plot([trace1, trace2], Layout(legend_title_text="Trend", showlegend=true))