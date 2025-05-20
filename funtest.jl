using LibSerialPort


ports = list_ports()
println(ports)

port = "/dev/ttyUSB17"
try
    sp = LibSerialPort.open(port, 115200)
    sp_flush(sp, SP_BUF_BOTH)
    #write(sp, "mtime \n")
    write(sp, "mslow\n")
    #write(sp, "helpfff\n")
    sleep(1)

    bytes_waiting = bytesavailable(sp) 
##array of type UInt8 with unitialized values, size of the data in input buffer
while bytes_waiting > 0
    myarray = Vector{UInt8}(undef, bytes_waiting)
    println("Found $bytes_waiting bytes in buffer")
    bytes_read = readbytes!(sp, myarray, bytes_waiting)
    #println("bytes_read worked")
    converted_data = String(myarray[1:bytes_read])
    #println("converted_data")
    println(converted_data)
    bytes_waiting = bytesavailable(sp)
    #println("bytes_waiting") 

end
    sp_flush(sp, SP_BUF_BOTH)
    close(sp)
    sleep(1)
catch e
    println("Failed to open $port. Error: ", e)
end
#The following commands are available:
# version   - Displays firmware version.
# clr       - Clear Motor Position Values
# mstop     - Set the desired stop position for motor
# mslow     - Set the desired position to start motor deceleration
# mtime     - Set the desired rise time for motor acceleration
# maxdc     - Set the desired max duty cycle for motor acceleration
# mode      - Set the desired mode
# pulse     - Set the pulse time
# mgoto     - Drive the motor to a specific position, relative to its current position
# mcount    - Set the total number of pulses (for continuous mode)
# mdelay    - Set the time in between pulses (for continuous mode)
# go        - Motor Drive Start
# back      - Motor Drive Back
# stop      - Motor Drive Stop
# dir       - Motor Direction Toggle
# pos       - Print Motor Position
# mstats    - Print Motor Error Stats
# sat       - Set the desired decel saturation point
# dcm       - Set the desired duty cycle for mode 0