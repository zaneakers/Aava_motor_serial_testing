using LibSerialPort

function send_and_read(sp, cmd)
    sp_flush(sp, SP_BUF_BOTH)
    write(sp, cmd * "\n")
    response = ""
    while  nbytes > 0
        nbytes = bytesavailable(sp)
        if nbytes > 0
            data = read(sp, nbytes)
            response *= String(data)        
        end
    end
    println("Sent: $cmd")
    println("Received:\n$response")
end

ports = list_ports()
println(ports)

port = "/dev/ttyUSB20"
try
    sp = LibSerialPort.open(port, 115200)
    sp_flush(sp, SP_BUF_BOTH)

    send_and_read(sp, "version")


    sp_flush(sp, SP_BUF_BOTH)
    close(sp)
    
catch e
    println("Failed to open $port. Error: ", e)
end