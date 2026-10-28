# 系統時脈 100MHz (Y9)[cite: 18]
set_property PACKAGE_PIN Y9 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# 系統重置 (正中間按鈕 BTNC)[cite: 31]
set_property PACKAGE_PIN P16 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# 週期選擇 (SW1, SW0)[cite: 30]
set_property PACKAGE_PIN F22 [get_ports {gear_period[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gear_period[0]}]
set_property PACKAGE_PIN G22 [get_ports {gear_period[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gear_period[1]}]

# 亮度上限選擇 (SW2)[cite: 31]
set_property PACKAGE_PIN H22 [get_ports gear_bright]
set_property IOSTANDARD LVCMOS33 [get_ports gear_bright]

# 解析度選擇 (SW4)[cite: 31]
set_property PACKAGE_PIN H19 [get_ports gear_res]
set_property IOSTANDARD LVCMOS33 [get_ports gear_res]

# PWM 呼吸燈輸出 (LED0)[cite: 31]
set_property PACKAGE_PIN T22 [get_ports pwm]
set_property IOSTANDARD LVCMOS33 [get_ports pwm]