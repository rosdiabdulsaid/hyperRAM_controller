


set usb [lindex [get_hardware_names] 0]
set device_name [lindex [get_device_names -hardware_name $usb] 0]
# puts [get_insystem_source_probe_instance_info -device_name $device_name -hardware_name $usb]
# exit
start_insystem_source_probe -device_name $device_name -hardware_name $usb

#instance 0:
#memr 5,memw 4,regr 3,regw 2,memrst 1 ,rst 0

# read cr0


# for {set index 5} { $index < 16 } { incr index } {
#      write_source_data -instance_index 0 -value 0x03 -value_in_hex
#     write_source_data -instance_index 0 -value 0x00 -value_in_hex
#     write_source_data -instance_index 3 -value $index -value_in_hex
#     write_source_data -instance_index 1 -value 0xC00000000000 -value_in_hex
#     write_source_data -instance_index 0 -value 0x08 -value_in_hex
#     write_source_data -instance_index 0 -value 0x00 -value_in_hex
#     set data [read_probe_data -instance_index 0 -value_in_hex]
#     if {$data == 0x0D83} {
#         puts "set latency   : $index"
#         break
#     } else {
#         puts "wrong data    : $data"
#         puts "expected data : 0x0D83"
#         puts "set latency   : $index"
#     }

#     after 1000
    
# }
# gets stdin
# # #write cr0
# write_source_data -instance_index 0 -value 0x01 -value_in_hex
# write_source_data -instance_index 0 -value 0x00 -value_in_hex
# write_source_data -instance_index 2 -value 0x8F1E -value_in_hex
# write_source_data -instance_index 1 -value 0x600001000000 -value_in_hex
# write_source_data -instance_index 0 -value 0x04 -value_in_hex
# write_source_data -instance_index 0 -value 0x00 -value_in_hex

# gets stdin
# #read reg
# write_source_data -instance_index 0 -value 0x3 -value_in_hex
# write_source_data -instance_index 0 -value 0x0 -value_in_hex
# write_source_data -instance_index 1 -value 0x0 -value_in_hex
# # write_source_data -instance_index 3 -value 0xe -value_in_hex
# # write_source_data -instance_index 0 -value 0x00 -value_in_hex
# write_source_data -instance_index 2 -value 0xc00001000000 -value_in_hex
# write_source_data -instance_index 1 -value 0x2 -value_in_hex
# puts [read_probe_data -instance_index 3 -value_in_hex]


# #write mem
# gets stdin
write_source_data -instance_index 0 -value 0x1 -value_in_hex
write_source_data -instance_index 0 -value 0x0 -value_in_hex
write_source_data -instance_index 1 -value 0x0 -value_in_hex
# write_source_data -instance_index 3 -value 0xe -value_in_hex
# write_source_data -instance_index 0 -value 0x00 -value_in_hex
write_source_data -instance_index 2 -value 0x000000000009 -value_in_hex
write_source_data -instance_index 5 -value 0xaa11bb22cc33dd44ee55ff66117722883399441055116612771388149915aa16 -value_in_hex
write_source_data -instance_index 1 -value 0x1 -value_in_hex


#read mem
gets stdin
write_source_data -instance_index 0 -value 0x1 -value_in_hex
write_source_data -instance_index 0 -value 0x0 -value_in_hex
write_source_data -instance_index 1 -value 0x0 -value_in_hex
# write_source_data -instance_index 3 -value 0xe -value_in_hex
# write_source_data -instance_index 0 -value 0x00 -value_in_hex
write_source_data -instance_index 2 -value 0x800000000000 -value_in_hex
write_source_data -instance_index 1 -value 0x2 -value_in_hex
puts [read_probe_data -instance_index 3 -value_in_hex]


# #write mem
# gets stdin
write_source_data -instance_index 0 -value 0x1 -value_in_hex
write_source_data -instance_index 0 -value 0x0 -value_in_hex
write_source_data -instance_index 1 -value 0x0 -value_in_hex
# write_source_data -instance_index 3 -value 0xe -value_in_hex
# write_source_data -instance_index 0 -value 0x00 -value_in_hex
write_source_data -instance_index 2 -value 0x000000000009 -value_in_hex
write_source_data -instance_index 5 -value 0xaa11bb22cc33dd44ee55ff66117722883399441055116612771388149915aa16 -value_in_hex
write_source_data -instance_index 1 -value 0x1 -value_in_hex


#read mem
gets stdin
write_source_data -instance_index 0 -value 0x1 -value_in_hex
write_source_data -instance_index 0 -value 0x0 -value_in_hex
write_source_data -instance_index 1 -value 0x0 -value_in_hex
# write_source_data -instance_index 3 -value 0xe -value_in_hex
# write_source_data -instance_index 0 -value 0x00 -value_in_hex
write_source_data -instance_index 2 -value 0x800000000000 -value_in_hex
write_source_data -instance_index 1 -value 0x2 -value_in_hex
puts [read_probe_data -instance_index 3 -value_in_hex]

# after 1000

# #read cr0
# write_source_data -instance_index 0 -value 0x01 -value_in_hex
# write_source_data -instance_index 0 -value 0x00 -value_in_hex
# write_source_data -instance_index 1 -value 0xc00001000000 -value_in_hex
# write_source_data -instance_index 0 -value 0x08 -value_in_hex
# write_source_data -instance_index 0 -value 0x00 -value_in_hex
# puts [read_probe_data -instance_index 0 -value_in_hex]

end_insystem_source_probe