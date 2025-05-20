using LibSerialPort


ports = list_ports()
println(ports)

port = "/dev/ttyUSB13"
try
    sp = LibSerialPort.open(port, 115200)
    sp_flush(sp, SP_BUF_BOTH)
    write(sp, "mslow\n")
    #write(sp, "helpfff\n")
    sleep(0.5)
    nbytes = bytesavailable(sp)
    if nbytes > 0
        data = read(sp, nbytes)
        println("Received: ", String(data))
    else
        println("No data received.")
    end
    nonblocking_read(sp)
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