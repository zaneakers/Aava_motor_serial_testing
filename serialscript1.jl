using LibSerialPort, Dataframes, CSV, Plots

list_ports()

sp = LibSerialPort.open("COM1", 115200) 
#allows configuring data framing parameters like ndatabits, parity, and nstopbits.
# deafult is 8N1

##clear both buffers, use default flow control
set_flow_control(sp)
sp_flush(sp, SP_BUF_BOTH)

## Test: write and immediately blocking_read a full line ending w newline char from input buffer
write(sp, "hello\n")
println(readline(sp))

##create containers to hold input (read) data
ADC_data = Float8[]
Positional_data = Int8[]
time = Int8[0] 
##read all data in input buffer
converted_data = parse(String, nonblocking_read(sp))  # Converts Vector{UInt8} byte array to string

## divide data into positional and ADC data ##
for m in eachmatch(r"\d+\.\d+|\d+", converted_data) 
    #matches floats first then ints, regex ignores spaces
    
    if occursin(r"\d+\.\d+", m.match) #check if match is a float 
        push!(ADC_data, parse(Float8, m.match))
        
    elseif occursin(r"\d+", m.match) #check if match is an int
        push!(Positional_data,parse(Int8, m.match))
    else
        println("match not working")
    end
    push!(time, time[end] + 0.05) #increment time by 0.00005 sec or 0.05 ms
end

df = DataFrame(Current=ADC_data, Position=Positional_data, Time = time)
plotcurrent = plot(df.Time, df.Current, label="Current", xlabel="Time (ms)", ylabel="Current", title="Current vs Time")
plotposition = plot(df.Time, df.Position, label="Position", xlabel="Time (ms)", ylabel="Position", title="Position vs Time")
CSV.write("motor_pos_adc.csv", df)

close(sp)

