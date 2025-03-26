set m [lindex [get_service_paths master] 0]
open_service master $m
set CSR_BA 0x4000000

master_read_32 $m [expr {$CSR_BA + 0x0}] 1
master_write_32 $m [expr {$CSR_BA + 0x0}] 0xaabbccdd
master_read_32 $m [expr {$CSR_BA + 0x0}] 1
gets stdin
master_read_32 $m [expr {$CSR_BA + 0x4}] 1
master_write_32 $m [expr {$CSR_BA + 0x4}] 0xababcdcd
master_read_32 $m [expr {$CSR_BA + 0x4}] 1
gets stdin
master_read_32 $m [expr {$CSR_BA + 0x8}] 1
master_write_32 $m [expr {$CSR_BA + 0x8}] 0x55667788
master_read_32 $m [expr {$CSR_BA + 0x8}] 1
gets stdin
master_read_32 $m [expr {$CSR_BA + 0xC}] 1
master_write_32 $m [expr {$CSR_BA + 0xC}] 0xaa1122bb
master_read_32 $m [expr {$CSR_BA + 0xC}] 1
gets stdin

puts [master_read_32 $m [expr {$CSR_BA + 0x0}] 4]

close_service master $m