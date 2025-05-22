using LibSerialPort, DataFrames, CSV
using PlotlyJS

### This script is used to read data from a serial port and parse it into a DataFrame

ports = list_ports()
println(ports)

port = "/dev/ttyUSB2"
sp = LibSerialPort.open(port, 115200) 
#open allows configuring data framing parameters like ndatabits, parity, and nstopbits.
# deafult is 8N1

##clear both buffers, use default(no flow control), flow control used to pause sender when needed

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
    yaxis=attr(title="Current"),
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
    write(sp, "mstop 378\r\n")
        smooth()
        readfunct()
    write(sp, "mslow 240\r\n")
        smooth()
        readfunct()
    write(sp, "mtime 40\r\n")
        smooth()
        readfunct()
    write(sp, "maxdc 80\r\n")
        smooth()
        readfunct()
    write(sp, "pulse 100\r\n")
        smooth()
        readfunct()
    write(sp, "mode 1\r\n")
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


minlen = minimum(length.([ADC_data, Positional_data, timey]))
df = DataFrame(
    Current = ADC_data[1:minlen],
    Position = Positional_data[1:minlen],
    Time = timey[2:minlen+1]  # skip initial 0.0
)

trace1 = PlotlyJS.scatter(x=df.Time, y=df.Position, mode="lines", name="Position vs Time",
    line=attr(color="black", width=2))
trace2 = PlotlyJS.scatter(x=df.Time, y=df.Current, mode="lines", name="Current vs Time",
    line=attr(color="black", width=2))

plt1 = PlotlyJS.plot(trace1, positionlayout)
plt2 = PlotlyJS.plot(trace2, currentlayout)
PlotlyJS.savefig(plt1, "position_plot.html")
PlotlyJS.savefig(plt2, "current_plot.html")
CSV.write("motor_pos_adc.csv", df)