"""
Basic line-buffering serial console.
Data is read  asynchronously from a serial device and user input is written
by line (not keypress).

If a serial device is connected that echoes bytes, each line of user input
should be duplicated.
"""

using LibSerialPort

sp2 = LibSerialPort.open("/dev/ttyUSB0", 115200)
write(sp2, "version\n")

    
mcu_message = ""

# Poll for new data without blocking
@async mcu_message *= String(nonblocking_read(sp))

# Send user input to device with ENTER

# Print response from device as a line
if occursin("\n", mcu_message)
    lines = split(mcu_message, "\n")
    while length(lines) > 1
        println(popfirst!(lines))
    end
    mcu_message = lines[1]
end

# Give the queued tasks a chance to run
sleep(0.0001)


