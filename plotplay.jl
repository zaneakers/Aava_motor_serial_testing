using PlotlyJS

x = range(0, 10, length=100)
y = sin.(x)
y_noisy = @. sin(x) + 0.1*randn()

trace1 = PlotlyJS.scatter(x=x, y=y, mode="lines", name="sin(x)", line=attr(color="black", width=2))
trace2 = PlotlyJS.scatter(x=x, y=y_noisy, mode="markers", name="data", marker=attr(color="red", size=6, opacity=0.5))

layout = Layout(
    title="Sine with noise, plotted with PlotlyJS",
    xaxis=attr(title="x"),
    yaxis=attr(title="y"),
    legend=attr(x=0.01, y=0.99)
)

plt = Plot([trace1, trace2], layout)
display(plt)

