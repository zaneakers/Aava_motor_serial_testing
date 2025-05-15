using LibSerialPort, DataFrames, CSV, Plots



### This script is used to read data from a serial port and parse it into a DataFrame

list_ports()

sp = LibSerialPort.open("COM1", 115200) 
#open allows configuring data framing parameters like ndatabits, parity, and nstopbits.
# deafult is 8N1

##clear both buffers, use default(no flow control)
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

##create plots
plotcurrent = plot(title="Real Time Current vs Time",xlabel="Time (ms)", 
                ylabel="Current",
                label="Current", legend=:topright)
plotposition = plot(title="Position vs Time", xlabel="Time (ms)", 
                ylabel="Position", 
                label="Position")
### find number of bytes in input buffer, create a new buffer, and read bytes into it

bytes_waiting = sp_input_waiting(sp) 
buffer = Vector{UInt8}(undef, bytes_waiting)
while bytes_waiting > 0
    println("Found $bytes_waiting bytes in buffer")
    bytes_read = readbytes!(sp, buffer, bytes_waiting)
    converted_data = String(buffer[1:bytes_read])

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
    plot!(plotcurrent, time, ADC_data, overwrite=true)
    display(plotcurrent)  
    plot!(plotposition, time, Positional_data, overwrite=true)
    display(plotposition)
end

df = DataFrame(Current=ADC_data, Position=Positional_data, Time = time)

CSV.write("motor_pos_adc.csv", df)

close(sp)

