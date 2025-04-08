set m [lindex [get_service_paths master] 0]
open_service master $m

proc wr {addr {m_path $m}} {
    master_write_32 $m_path $addr 0x1
}

proc rd {addr {m_path $m}} {
    master_read_32 $m_path $addr 0x1
}



