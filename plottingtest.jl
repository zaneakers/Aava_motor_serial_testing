using  DataFrames, CSV
using PlotlyJS


using Random

n = 100  # number of data points
ADC_data = rand(Float16, n)
Positional_data = rand(UInt16, n)
time = collect(Float16, 0.0:1.0:(n-1))


currentlayout = Layout(
    title="Real Time Current vs Time",
    xaxis=attr(title="Time (ms)"),
    yaxis=attr(title="Current (A)"),
    legend=attr(x=0.01, y=0.99)
)
positionlayout = Layout(
    title="Position vs Time",
    xaxis=attr(title="Time (ms)"),
    yaxis=attr(title="Position"),
    legend=attr(x=0.01, y=0.99)
)

function write(a, b)
    println(b)
    println(a)
end
    sp = "hello"

    write(sp, "\n")
        
    cmd1 = "mstop 378"
    write(sp, "$cmd1\r\n")
    
    write(sp, "mslow 240\r\n")
        
    write(sp, "mtime 40\r\n")
        
    write(sp, "maxdc 80\r\n")
        
    write(sp, "pulse 100\r\n")
        
    write(sp, "mode 1\r\n")
        
write(sp, "go\r\n")


df = DataFrame(Current=ADC_data, Position=Positional_data, Time = time)

trace1 = PlotlyJS.scatter(x=df.Time, y=df.Position, mode="lines", name="$cmd1",
    line=attr(color="black", width=2), showlegend=true)
trace2 = PlotlyJS.scatter(x=df.Time, y=df.Current, mode="lines", name="$cmd1<br>$cmd1<br>$cmd1",
    line=attr(color="black", width=2), showlegend=true)

plt1 = PlotlyJS.plot(trace1, positionlayout)
plt2 = PlotlyJS.plot(trace2, currentlayout)
display(plt1)
display(plt2)
#CSV.write("motor_pos_adc.csv", df)

##Plotting code works

