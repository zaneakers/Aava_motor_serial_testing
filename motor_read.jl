using LibSerialPort

#will integrate into motor_write_read.jl
#assume both buffers are cleared

write(sp, "mstop\n")
#need to know parameters for each command