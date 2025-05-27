using LibSerialPort, DataFrames, CSV
using PlotlyJS

### This script is used to read data from a serial port and parse it into a DataFrame

ports = list_ports()
println(ports)

port = "/dev/ttyUSB2"
sp = LibSerialPort.open(port, 115200) 


#flush input and output buffers
sp_flush(sp, SP_BUF_BOTH)

##create containers to hold input (read) data
ADC_data = Float16[]
Positional_data = UInt16[]
timey = Float16[0.0] 
##create plotlyjs figure
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
##create plots

############WRITE############################

    function smooth()
        #println("before drain", sp_output_waiting(sp))
        sleep(0.2)
        sp_drain(sp)
        #println("after drain", sp_output_waiting(sp)) - always zero, checks how many bytes in output buffer
        
    end

    function readfunct()
        #println("before read", bytesavailable(sp))
        data=nonblocking_read(sp)
        sleep(0.2)
        #println("after read", bytesavailable(sp)) #- checks how many bytes in input buffer
        println(String(data))
        sleep(0.2)
    end

    #######Values chosen############
mstopvalue = "378"
mslowvalue = "240"
mtimevalue = "40"
maxdctime = "80"
pulsevalue = "100"
modevalue = "1"
Parameters = ["mstop $mstopvalue\r\n", "mslow $mslowvalue\r\n", "mtime $mtimevalue\r\n", 
"maxdc $maxdctime\r\n", "pulse $pulsevalue\r\n", "mode $modevalue\r\n"]


    emptybuff = []
    write(sp, "\n")
        sleep(0.2)
        smooth()
        readfunct()
    write(sp, "version\r\n")
        smooth()
        readfunct()
        sp_flush(sp, SP_BUF_BOTH)
        sleep(0.1)
    
    write(sp, Parameters[1])
        smooth()
        readfunct()
    
    write(sp, Parameters[2])
        smooth()
        readfunct()
    
    write(sp, Parameters[3])
        smooth()
        readfunct()
    
    write(sp, Parameters[4])
        smooth()
        readfunct()
    
    write(sp, Parameters[5])
        smooth()
        readfunct()
    
    write(sp, Parameters[6])
        smooth()
        readfunct()
    write(sp, "go\r\n")
        smooth()
        readfunct()
############READ#############################
### find number of bytes in input buffer, create a new buffer, and read bytes into it

sleep(9)
##array of type UInt8 with unitialized values, size of the data in input buffer
while bytesavailable(sp) > 0
    nbytes = bytesavailable(sp)
    myarray = Vector{UInt8}(undef, nbytes)
    println("Found $nbytes bytes in buffer")
    bytes_read = readbytes!(sp, myarray, nbytes)
    converted_data = String(myarray[1:bytes_read])
    println("converted data ", converted_data)
    ## divide data into positional and ADC data ##
    for m in eachmatch(r"\d+\.\d+|\d+", converted_data) 
    #matches floats first then ints, regex ignores spaces
        
        if occursin(r"\d+\.\d+", m.match) #check if match is a float 
            push!(ADC_data, parse(Float16, m.match))
            
        elseif occursin(r"\d+", m.match) #check if match is an int
            push!(Positional_data,parse(UInt16, m.match))
        else
            println("match not working")
        end
        push!(timey, timey[end] + 0.05) #increment timey by 0.05 ms for every match
    end
    
end
sleep(0.5)
write(sp, "\n")
write(sp, "stop\r\n")

close(sp)
sleep(1)

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
 # collect all current traces
p = make_subplots(rows=1, cols=1, specs = fill(Spec(kind="xy"), 1, 1),
shared_xaxes=true, vertical_spacing=0.02)


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
        add_trace!(p, trace, row=1, col=1)
    end
    relayout!(p, title_text="testingthingy1")
end
PlotlyJS.savefig(p, "position_plot2.html")
PlotlyJS.savefig(p, "position_plot2.png")

p2 = make_subplots(rows=1, cols=1, specs = fill(Spec(kind="xy"), 1, 1),
shared_xaxes=true, vertical_spacing=0.02)

# Now plot all found traces together
for numb in 0:9
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
        add_trace!(p2, trace, row=1, col=1)
    end
    relayout!(p2, title_text="testingthingy2")
end
PlotlyJS.savefig(p2, "current_plot2.html")
PlotlyJS.savefig(p, "current_plot2.png")

