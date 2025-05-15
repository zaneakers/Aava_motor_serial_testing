
using PlotlyJS   # set the backend to Plotly

x = range(0, 10, length=100)
y = sin.(x)
y_noisy = @. sin(x) + 0.1*randn()

# this plots into a standalone window via Plotly
plot(x, y, label="sin(x)", lc=:black, lw=2)
scatter!(x, y_noisy, label="data", mc=:red, ms=2, ma=0.5)
plot!(legend=:bottomleft)
title!("Sine with noise, plotted with Plotly")
xlabel!("x")
ylabel!("y")