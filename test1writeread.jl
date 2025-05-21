using LibSerialPort


ports = list_ports()
println(ports)

port = "/dev/ttyUSB1"

#input buffer for laptop holds the output of the device
#output buffer for laptop holds data to be sent to device

try
    sp = LibSerialPort.open(port, 115200)

    ###CHECK###
    nbytes = bytesavailable(sp) #non blocking, deterimine serial data in input/receive buffer
    println(nbytes)

    write(sp, "\nversion\n")
    sp_drain(sp)
    sleep(0.5)

    ###CHECK###
    nbytes = bytesavailable(sp)
    println(nbytes)

    #same as a nonblocking_read? no, nonblocking read outputs in vector(UINT8) form, w bit values
    if nbytes > 0
        data = read(sp, nbytes)
        println("Received: ", String(data))

    else
        println("No data received.")
    end
    sleep(0.5)
    write(sp, "mstop 589\n")
    sp_drain(sp)
    sleep(0.5)

    ###CHECK###
    nbytes = bytesavailable(sp)
    println(nbytes)

    println(String(read(sp)))


    sleep(0.5)
    close(sp)
   
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