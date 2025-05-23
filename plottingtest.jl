using  DataFrames, CSV
using PlotlyJS


using Random

n = 100  # number of data points
ADC_data = rand(Float16, n)
Positional_data = rand(UInt16, n)
timey = collect(Float16, 0.0:1.0:(n-1))


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

#################WRITING#############################
function write(a, b)
    println(b)
    println(a)
end
mstopvalue = "378"
mslowvalue = "240"
mtimevalue = "40"
maxdctime = "80"
pulsevalue = "100"
modevalue = "1"
Parameters = ["mstop $mstopvalue", "mslow $mslowvalue", "mtime $mtimevalue", "maxdc $maxdctime", "pulse $pulsevalue", "mode $modevalue"]

    sp = "hello"

    write(sp, Parameters[1])
    
    write(sp, Parameters[2])
       
    write(sp, Parameters[3])
      
    write(sp, Parameters[4])
     
    write(sp, Parameters[5])
    
    write(sp, Parameters[6])
     
######Dataframe############

minlen = minimum(length.([ADC_data, Positional_data, timey]))
newdf = DataFrame(
    Current = ADC_data[1:minlen],
    Position = Positional_data[1:minlen],
    Time = timey[1:minlen]  # skip initial 0.0
)

##pad the parameters column with missing values 
padded= vcat(Parameters, fill(missing, nrow(newdf) - length(Parameters)))
parameterdf = DataFrame(Parameters = padded)
#combine data dataframe and list of parameters dataframe
newandparameterdf = hcat(parameterdf, newdf)

#########################CSV file########################################################
csvfile = "motor_postest6_adc.csv"
###check to make sure file exists before comparison
if isfile(csvfile)
    firstdf = CSV.read(csvfile, DataFrame)

    firstdfheader = [first(firstdf[!, col], 5) for col in names(firstdf)]
    newdfheader = [first(newdf[!, col], 5) for col in names(newdf)]
        
    if newdfheader != firstdfheader # if headers different, add to file
        df_mostrecent = hcat(firstdf, newdf, makeunique=true)
        CSV.write(csvfile, df_mostrecent)
        notequal = true

    else# if headers are same and file exists, do nothing
            println("values are the same, no change to file")
    end

else
    df_mostrecent = newandparameterdf
    CSV.write(csvfile, df_mostrecent)

end

###################PLOTTING#############################
#make string of parameters to put in legend of plots
namey = join(Parameters, "<br> ")

#traces = scatter[]  # collect all traces in an array
traceinitial = DataFrame()
for numb in 0:9
    colname = "Position_$numb"
    if colname in names(df_mostrecent)
        trace = PlotlyJS.scatter(
            x = df_mostrecent.Time,
            y = df_mostrecent[!, colname],
            mode = "lines",
            name = "Settings--- <br> $namey <br> $colname",
            line = attr(width=2),
            showlegend = true
        )
        traces = vcat(traceintial, trace)
        traceinitial = traces
    end
    
end

# Now plot all found traces together
plotallposition = PlotlyJS.plot(traces, positionlayout)

current_traces = scatter[]  # collect all current traces

for numb in 1:9
    colname = "Current_$numb"
    if colname in names(df_mostrecent)
        trace = PlotlyJS.scatter(
            x = df_mostrecent.Time,
            y = df_mostrecent[!, colname],
            mode = "lines",
            name = "Settings--- <br> $namey <br> $colname",
            line = attr(width=2),
            showlegend = true
        )
        push!(current_traces, trace)
    end
end

# Plot all found current traces together
plotallcurrent = PlotlyJS.plot(current_traces, currentlayout)
