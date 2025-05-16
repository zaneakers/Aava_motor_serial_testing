using LibSerialPort

#will integrate into motor_write_read.jl
#assume both buffers are cleared
##be able to loop through a range of parameters for each command

println("Enter a command:")
command = readline()
if command=="mstop"
    println("Enter a range of values for mstop:")
    x = parse(Int8, readline())
    write(sp, "mstop($x)\n")
elseif command=="mslow"
    println("Enter position to start deaceleration:")
    x = parse(Int8, readline())
    write(sp, "mslow($x)\n")
elseif command=="mtime"
    println("Enter desired rise time")
    x = parse(Int8, readline())
    write(sp, "mtime($x)\n")
elseif command=="sat"
    println("Enter desired decel saturation point:")
    x = parse(Int8, readline())
    write(sp, "sat($x)\n")

end


