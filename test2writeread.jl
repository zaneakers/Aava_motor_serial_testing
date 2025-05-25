using PlotlyJS

p = make_subplots(rows=3, cols=1, shared_xaxes=true, vertical_spacing=0.02)
add_trace!(p, scatter(x=0:2, y=10:12), row=3, col=1)
add_trace!(p, scatter(x=2:4, y=100:10:120), row=2, col=1)
add_trace!(p, scatter(x=3:5, y=1000:100:1200), row=1, col=1)
relayout!(p, title_text="Stacked Subplots with Shared X-Axes")
p