using LibSerialPort

#will integrate into motor_write_read.jl
#assume both buffers are cleared
##be able to loop through a range of parameters for each command

println("Enter a command:")
command = readline()
if command=="mstop"
    println("Enter a range of values for mstop:")
    x = parse(Int8, readline())
    write(sp, "mstop($x)\n")
elseif command=="mslow"
    println("Enter position to start deaceleration:")
    x = parse(Int8, readline())
    write(sp, "mslow($x)\n")
elseif command=="mtime"
    println("Enter desired rise time")
    x = parse(Int8, readline())
    write(sp, "mtime($x)\n")
elseif command=="sat"
    println("Enter desired decel saturation point:")
    x = parse(Int8, readline())
    write(sp, "sat($x)\n")

end

####PLOTTTING SCRIPT######
df = DataFrame(Current=ADC_data, Position=Positional_data, Time = time)

trace1 = PlotlyJS.scatter(x=df.Time, y=df.Position, mode="lines", name="Position vs Time",
    line=attr(color="black", width=2))
trace2 = PlotlyJS.scatter(x=df.Time, y=df.Current, mode="lines", name="Current vs Time",
    line=attr(color="black", width=2))

plt1 = PlotlyJS.plot(trace1, positionlayout)
plt2 = PlotlyJS.plot(trace2, currentlayout)
display(plt1)
display(plt2)
CSV.write("motor_pos_adc.csv", df)
