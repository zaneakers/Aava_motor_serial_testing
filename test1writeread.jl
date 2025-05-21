using LibSerialPort


ports = list_ports()
println(ports)

port = "/dev/ttyUSB6"

#input buffer for laptop holds the output of the device
#output buffer for laptop holds data to be sent to device
#not a sleep issue
#echo included consistently, message infrequently included
#clumping issue, mstop only returns error 003 if given multiple parameters,
# which could most likely occur if the version command ended up mixed with it 
#in the output buffer,

try
    sp = LibSerialPort.open(port, 115200)
    emptybuff = []
    sp_flush(sp, SP_BUF_BOTH)

    write(sp, "\n")
    sp_drain(sp)
    sleep(0.05)
     ###CHECK###
    nbytes = bytesavailable(sp) #non blocking, deterimine serial data in input/receive buffer
    println(nbytes)
    data=String(read(sp))
    push!(emptybuff, data)
    println(data)

    write(sp, "\n")
    sp_drain(sp)
    sleep(0.05)
     ###CHECK###
    nbytes = bytesavailable(sp) #non blocking, deterimine serial data in input/receive buffer
    println(nbytes)
    data=String(read(sp))
    push!(emptybuff, data)
    println(data)
    sleep(0.05)

    write(sp, "mstop 589\n")
    sp_drain(sp)
    sleep(0.05)
     ###CHECK###
    nbytes = bytesavailable(sp) #non blocking, deterimine serial data in input/receive buffer
    println(nbytes)
    println("Going to read all available mstop bytes from sp")
    data=String(read(sp))
    push!(emptybuff, data)
    println(data)
    sleep(0.05)

    close(sp)
    println(emptybuff)
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