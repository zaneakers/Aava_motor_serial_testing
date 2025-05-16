using LibSerialPort, DataFrames, CSV
using PlotlyJS

### This script is used to read data from a serial port and parse it into a DataFrame

list_ports()

sp = LibSerialPort.open("COM1", 115200) 
#open allows configuring data framing parameters like ndatabits, parity, and nstopbits.
# deafult is 8N1

##clear both buffers, use default(no flow control), flow control used to pause sender when needed
set_flow_control(sp)
#flush input and output buffers
sp_flush(sp, SP_BUF_BOTH)

## Test: write and immediately blocking_read a full line ending w newline char from input buffer
write(sp, "hello\n")
println(readline(sp))

##create containers to hold input (read) data
ADC_data = Float16[]
Positional_data = UInt16[]
time = Float16[0.0] 
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

### find number of bytes in input buffer, create a new buffer, and read bytes into it

bytes_waiting = sp_input_waiting(sp) 
##array of type UInt8 with unitialized values, size of the data in input buffer
while bytes_waiting > 0
    myarray = Vector{UInt8}(undef, bytes_waiting)
    println("Found $bytes_waiting bytes in buffer")
    bytes_read = readbytes!(sp, myarray, bytes_waiting)
    converted_data = String(myarray[1:bytes_read])

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
        push!(time, time[end] + 0.05) #increment time by 0.05 ms for every match
    end
    bytes_waiting = sp_input_waiting(sp)
    
end

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

close(sp)

