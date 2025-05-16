using LibSerialPort

#will integrate into motor_write_read.jl
#assume both buffers are cleared


println("Enter a command:")
command = readline()
if command=="mstop"
    println("Enter a value for mstop:")
    x = parse(Int8, readline())
    write(sp, "mstop($x)\n")
elseif command=="mslow"
    println("Enter position to start deaceleration:")
    x = parse(Int8, readline())
    write(sp, "mslow($x)\n")

