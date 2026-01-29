# Overview

## Introduction

In this project, we developed a VGA Controller in VHDL and implemented it on a physical digital circuit development board (Nexys Video).
Our primary objective was to design the display portion of a standard oscilloscope, featuring movable triggers and functional channel switching.

# Design & Implementation

Figures 1 and 2 below illustrate the oscilloscope grid diagram we aimed to display and the overall block diagram that guided our design and development process.

![Figure 1: Oscilloscope Grid Diagram](ece383_wksp/lab1/Oscilloscope_Coordinate_plane.png)
_Figure 1: Oscilloscope Grid Diagram_

This diagram helped us identify the numbering for the horizontal and vertical grid, box positions, hash marks, and trigger sizes. It provided actionable insight for implementing these primary display features and was especially useful for defining the spacing and numbering needed to render professional-looking hashes.

![Figure 2: Block Diagram](ece383_wksp/lab1/Oscilloscope%20Grid%20Diagram.png)
_Figure 2: Block Diagram_

We will now break down the components, focusing on the sections we primarily developed. Working from the inside out, we start with the horizontal and vertical counters. The horizontal counter counts from 0 to 799 (pixels per row), and the vertical counter counts from 0 to 524 (rows). We adopted the standard front- and back-porch convention for video signal timing. The actual screen size is 640x480, with the horizontal porch, sync, and back porch taking up 160 pixels per row, and the vertical porch occupying 45 rows.

Each counter uses clk, reset_n, and ctrl inputs (control between a hold state or increment on rising clock edge state), all as std_logic. The horizontal counter's roll output connects to the vertical counter's ctrl input, enabling the counters to count each row after all pixels in that row are processed.

The counters are contained within the vga_signal_generator module, which generates the VGA signal by sweeping across the display from left to right, then returning to the left side of the next lower row. This component uses clk and reset_n (std_logic), and outputs position and vga signals using the coordinate_t and vga_t record types. The coordinate_t type tracks the current pixel row and column, while vga_t holds the hsync, vsync, and blank signals to indicate when drawing is out of bounds according to porch and sync conventions.

Another key component, at the same level of design as the vga_signal_generator within the vga module, is the color_mapper. This module relies solely on combinational logic. Given a row and column, it generates the RGB value for that pixel. Inputs include ch1 and ch2 (channel_t), position (coordinate_t), and trigger (trigger_t). The output is color (color_t). The channel_t type indicates channel activity, trigger_t specifies time or voltage trigger, and color_t is a 24-bit value (red, green, blue).

The vga module contains two instances of vga_signal_generator and color_mapper. It uses clk, reset_n, ch1, ch2, and trigger as inputs, with vga and pixel as outputs. The pixel_t record type combines coordinate and color information for each pixel.

The video module, which was provided to us, is not discussed in depth here as it was not part of our main development.

Alongside the video module, under the top file (lab1), is our numeric stepper. This stepper includes debouncing logic to enable trigger movement, allowing a step size delta (10 pixels) along the display and activating specific flags necessary to do so. It uses clk, reset_n, en, up, down (std_logic inputs), and a signed output q.

Finally, our top file acts as the overarching module that connects these lower-level modules and their logic to the hardware. Inputs include clk, reset_n, btn[4:0], and sw[1:0], while outputs include led[4:0], tmds[3:0], and tmdsb[3:0].

# Test and Debug

Throughout the testing and debugging phase, we relied primarily on the modular testbenches provided: vga_log_tb, NumStepper_tb, and instructor_tb. For testbenches involving signal generation, we conducted deep analysis of the signals to resolve issues. We also collaborated with other students, as multiple minds often work better than one when facing challenging problems.

As required, below are three excerpts from the vga_module, shown as figures 3, 4, and 5:

![Figure 3: hsync signal transitions (high, low, high) in relation to column count.](ece383_wksp/lab1/figure3.png)
_Figure 3: hsync signal transitions (high, low, high) in relation to column count._

![Figure 4: vsync signal transitions (high, low, high) in relation to both row and column count.](ece383_wksp/lab1/figure4.png)
_Figure 4: vsync signal transitions (high, low, high) in relation to both row and column count._

![Figure 5: blank signal transitions (high, low, high) in relation to column and row count.](ece383_wksp/lab1/figure5.png)
_Figure 5: blank signal transitions (high, low, high) in relation to column and row count._

![Figure 6: column count rolling over causing the row count to increment and max counts for both counters](ece383_wksp/lab1/figure6.png)
_Figure 6: column count rolling over causing the row count to increment and max counts for both counters_

Major problems, such as trigger and hash mark logic not generating properly or passing specific tests, were solved through a conceptual conversation with other students (as referenced in the documentation). They provided better insight and a more reliable method for these items in the color_mapper, improving upon our initial brute-force approach. Additionally, syntax and minor logic issues—especially those related to the front porch, sync, and back porch flags—were resolved using the vga_log_tb. We also learned the importance of running simulations for a sufficient duration, as this was initially overlooked during our early testing stages.

# Results

Each milestone and gate check—except for gate check 1, which was impacted by extenuating circumstances—was achieved at least one day ahead of schedule. For gate check 1, I did not submit the correct waveform and was off by one row count, missing the rollover from 524 to 0. However, the functionality worked during submission; the issue was solely a submission error. As a result, gate check 1 was only partially achieved.

The remaining gate checks and the overall system were fully functional and met all requirements by the end of the project. Gate checks 2 and 3 were successfully achieved. The highlights below demonstrate progressive accomplishment throughout development.

![Figure 7: Gate Check 2 Passing all Cases](ece383_wksp/lab1/figure7.png)
_Figure 7: Gate Check 2 Passing all Cases_

![Figure 8: Successful Online VGA Simulator Display (vga_log_tb for color_mapper file)](ece383_wksp/lab1/figure8.png)
_Figure 8: Successful Online VGA Simulator Display (vga_log_tb for color_mapper file)_

As an aside, the code was not pushed to GitHub in stages until the very end, leaving this as the only primary component that was not achieved.

# Conclusion

Overall, this lab was a valuable learning experience. I learned to break down complex issues into small, actionable steps and to use a modular testing approach. This process also highlighted the importance of asking questions and discussing problems—talking through challenges often led to key insights and solutions. Many issues were resolved simply by articulating them out loud.

One recommendation for future iterations of this lab is to provide more context on how the modules interact with each other,both conceptually and physically. Having a stronger conceptual map from the beginning would make it easier to start the coding process and understand the overall system.
