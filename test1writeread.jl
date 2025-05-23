using LibSerialPort

port = "/dev/ttyUSB4"
println(list_ports())


try
    sp = LibSerialPort.open(port, 115200)
    #set_flow_control(sp; xonxoff=SP_XONXOFF_INOUT, rts=SP_RTS_ON, dtr=SP_DTR_ON)
    
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
        #push!(emptybuff, data)
        sleep(0.2)
    end

    sp_flush(sp, SP_BUF_BOTH)
    println(bytesavailable(sp))
    println(sp_output_waiting(sp))
    
    emptybuff = []
    write(sp, "\n")
        sleep(0.2)
        smooth()
        readfunct()
    write(sp, "dcm 30\r\n")
        smooth()
        readfunct()
        #sp_flush(sp, SP_BUF_BOTH)
        sleep(0.1)
    write(sp, "\r\n")
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
    
    sp_flush(sp, SP_BUF_BOTH)
    println(bytesavailable(sp))
    println(sp_output_waiting(sp))
    
    close(sp)

    
    for s in emptybuff
        println(String(s))
    end
    

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