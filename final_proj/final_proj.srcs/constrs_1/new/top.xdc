##---------------------------------------------------------------
## Final Project XDC for Nexys Video (Rev. A)
## ECE 383 - NES-controlled robotic arm
## Top entity: top
## Verified against Digilent Nexys-Video-Master.xdc
##---------------------------------------------------------------

## 100 MHz system clock
set_property -dict { PACKAGE_PIN R4    IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];

## CPU_RESET pushbutton (active low) -> reset_n
set_property -dict { PACKAGE_PIN G4    IOSTANDARD LVCMOS15 } [get_ports { reset_n }];

##---------------------------------------------------------------
## Pmod JA - NES controller interface
## JA1 (AB22) = nes_latch
## JA2 (AB21) = nes_pulse
## JA3 (AB20) = nes_data
## JA5 = GND, JA6 = VCC (3.3V)
##---------------------------------------------------------------
set_property -dict { PACKAGE_PIN AB22  IOSTANDARD LVCMOS33 } [get_ports { nes_latch }];
set_property -dict { PACKAGE_PIN AB21  IOSTANDARD LVCMOS33 } [get_ports { nes_pulse }];
set_property -dict { PACKAGE_PIN AB20  IOSTANDARD LVCMOS33 } [get_ports { nes_data  }];

##---------------------------------------------------------------
## Pmod JB - 6 PWM outputs to servos
## JB1 (V9) = pwm_out[0] (base)
## JB2 (V8) = pwm_out[1] (shoulder)
## JB3 (V7) = pwm_out[2] (elbow)
## JB4 (W7) = pwm_out[3] (wrist pitch)
## JB7 (W9) = pwm_out[4] (wrist rotate)
## JB8 (Y9) = pwm_out[5] (gripper)
## JB5 = GND (tie to external supply ground!)
##---------------------------------------------------------------
set_property -dict { PACKAGE_PIN V9    IOSTANDARD LVCMOS33 } [get_ports { pwm_out[0] }];
set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33 } [get_ports { pwm_out[1] }];
set_property -dict { PACKAGE_PIN V7    IOSTANDARD LVCMOS33 } [get_ports { pwm_out[2] }];
set_property -dict { PACKAGE_PIN W7    IOSTANDARD LVCMOS33 } [get_ports { pwm_out[3] }];
set_property -dict { PACKAGE_PIN W9    IOSTANDARD LVCMOS33 } [get_ports { pwm_out[4] }];
set_property -dict { PACKAGE_PIN Y9    IOSTANDARD LVCMOS33 } [get_ports { pwm_out[5] }];

##---------------------------------------------------------------
## LEDs LD0, LD1, LD2 -> selected joint indicator
##---------------------------------------------------------------
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS25 } [get_ports { led_selected[0] }];
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS25 } [get_ports { led_selected[1] }];
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS25 } [get_ports { led_selected[2] }];

## Configuration options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]