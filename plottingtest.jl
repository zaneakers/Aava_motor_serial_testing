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
newdf = DataFrame(Current=ADC_data, Position=Positional_data, Time = time)

##pad the parameters column with missing values 

padded= vcat(Parameters, fill(missing, nrow(newdf) - length(Parameters)))
parameterdf = DataFrame(Parameters = padded)
for r in eachrow(parameterdf)
    println(r)
end
newandparameterdf = hcat(parameterdf, newdf)

###################PLOTTING#############################
namey = join(Parameters, "<br> ")

trace1 = PlotlyJS.scatter(x=newdf.Time, y=newdf.Position, mode="lines", name="Settings--- <br> $namey",
    line=attr(color="black", width=2), showlegend=true)
trace2 = PlotlyJS.scatter(x=newdf.Time, y=newdf.Current, mode="lines", name="Settings <br> $namey",
    line=attr(color="black", width=2), showlegend=true)

plt1 = PlotlyJS.plot(trace1, positionlayout)
plt2 = PlotlyJS.plot(trace2, currentlayout)
#display(plt1)
#display(plt2)

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

    else# if headers are same and file exists, do nothing
            println("values are the same, no change to file")
    end

else
    CSV.write(csvfile, newandparameterdf)
end
### comparison between old and new data###
##create headers from both dataframes each containing first 5 values of each column




##Plotting code works

