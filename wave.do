onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 20 UUT_TOP_MODULE
add wave -noupdate /tb_spi_case1/UUT_TOP/CLK
add wave -noupdate /tb_spi_case1/UUT_TOP/RST_N
add wave -noupdate /tb_spi_case1/UUT_TOP/TX_DATA_VALID_M
add wave -noupdate /tb_spi_case1/UUT_TOP/TX_DATA_S
add wave -noupdate /tb_spi_case1/UUT_TOP/TX_DATA_M
add wave -noupdate /tb_spi_case1/UUT_TOP/RX_DATA_M
add wave -noupdate /tb_spi_case1/UUT_TOP/RX_DATA_VALID_M
add wave -noupdate /tb_spi_case1/UUT_TOP/RX_DATA_S
add wave -noupdate /tb_spi_case1/UUT_TOP/RX_DATA_VALID_S
add wave -noupdate /tb_spi_case1/UUT_TOP/SCLK_w
add wave -noupdate /tb_spi_case1/UUT_TOP/SS_N_w
add wave -noupdate /tb_spi_case1/UUT_TOP/MOSI_w
add wave -noupdate /tb_spi_case1/UUT_TOP/MISO_w
add wave -noupdate -divider -height 20 UUT_MASTER_MODULE
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/CLK
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/RST_N
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/TX_DATA
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/TX_DATA_VALID
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/MISO
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/MOSI
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/SCLK
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/SS_N
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/RX_DATA
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/RX_DATA_VALID
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/sample_edge
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/TX_SHIFT_REGISTER
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/RX_SHIFT_REGISTER
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/TX_BIT_COUNTER
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/RX_BIT_COUNTER
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/SS_N_INT
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_MASTER/SCLK_INT
add wave -noupdate -divider -height 20 UUT_SLAVE_MODULE
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_SLAVE/SCLK
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_SLAVE/SS_N
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_SLAVE/MOSI
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_SLAVE/MISO
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_SLAVE/RST_N
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_SLAVE/RX_DATA
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_SLAVE/RX_DATA_VALID
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_SLAVE/TX_DATA
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_SLAVE/TX_SHIFT_REGISTER
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_SLAVE/RX_SHIFT_REGISTER
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_SLAVE/TX_BIT_COUNTER
add wave -noupdate /tb_spi_case1/UUT_TOP/UUT_SLAVE/RX_BIT_COUNTER
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {97836 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {787500 ps}
