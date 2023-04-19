vlib work
vmap work work

vlog -work work submodules_tb.sv

vsim -novopt work.partial_sum_tb

onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate {/partial_sum_tb/intf[0]/status}
add wave -noupdate {/partial_sum_tb/intf[0]/req}
add wave -noupdate {/partial_sum_tb/intf[0]/ack}
add wave -noupdate {/partial_sum_tb/intf[0]/data}

add wave -noupdate {/partial_sum_tb/intf[1]/status}
add wave -noupdate {/partial_sum_tb/intf[1]/req}
add wave -noupdate {/partial_sum_tb/intf[1]/ack}
add wave -noupdate {/partial_sum_tb/intf[1]/data}

add wave -noupdate {/partial_sum_tb/intf[2]/status}
add wave -noupdate {/partial_sum_tb/intf[2]/req}
add wave -noupdate {/partial_sum_tb/intf[2]/ack}
add wave -noupdate {/partial_sum_tb/intf[2]/data}

add wave -noupdate {/partial_sum_tb/intf[3]/status}
add wave -noupdate {/partial_sum_tb/intf[3]/req}
add wave -noupdate {/partial_sum_tb/intf[3]/ack}
add wave -noupdate {/partial_sum_tb/intf[3]/data}

add wave -noupdate {/partial_sum_tb/intf[4]/status}
add wave -noupdate {/partial_sum_tb/intf[4]/req}
add wave -noupdate {/partial_sum_tb/intf[4]/ack}
add wave -noupdate {/partial_sum_tb/intf[4]/data}

add wave -noupdate {/partial_sum_tb/intf[5]/status}
add wave -noupdate {/partial_sum_tb/intf[5]/req}
add wave -noupdate {/partial_sum_tb/intf[5]/ack}
add wave -noupdate {/partial_sum_tb/intf[5]/data}

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 fs} 0}
configure wave -namecolwidth 246
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits fs
update
WaveRestoreZoom {0 fs} {836 fs}

run -all