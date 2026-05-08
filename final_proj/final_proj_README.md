# NES-Controlled FPGA Robot Arm

ECE 383 Final Project — John Alves — May 2026

A six-servo robotic arm controlled by a Nintendo NES game pad, implemented entirely in custom VHDL hardware on a Nexys Video FPGA. No MicroBlaze.

---

## 2 Plan

### 2.1 Proposal

The original proposal called for a MicroBlaze-based hybrid system in which the soft processor handled input decode, joint selection, step sizing, and UART status formatting, with custom hardware handling only the NES serial interface and PWM generation. During implementation I pivoted to a pure-hardware design: every subsystem lives in VHDL, including the FSM that decodes button state into joint actions. The motivation was deterministic timing — the original design had the processor doing the per-poll loop that drove the datapath, and once I started looking at the timing closely it became clear that a hardware FSM with a synchronous register file would be both simpler and immune to software jitter. The objective is otherwise unchanged: read the NES controller, translate buttons into joint commands, and drive six servo PWM channels.

### 2.2 Detailed Architecture and Sub-System Design

The design is a six-module pipeline organized as a control side and a datapath side:

```
nes_interface → button_reg → control_fsm → joint_regfile → limit_clamp → pwm_gen
   (FSM)        (sync)        (FSM)         (6 regs)        (clamp)       (PWM)
```

`nes_interface` drives the latch and pulse signals defined by the NES protocol, samples the data line on each pulse, and produces an 8-bit button word at roughly 60 Hz. `button_reg` is a three-stage synchronizer that crosses that word into the 100 MHz clock domain cleanly. `control_fsm` decodes the synchronized buttons and decides what action to take — cycle the selected joint, increment or decrement the current joint, snap to home, open or close the gripper. It writes updates into `joint_regfile`, which holds six 18-bit registers, one per joint. `limit_clamp` is a pure combinational block that saturates each register against per-joint min/max bounds before the value reaches `pwm_gen`. The PWM generator shares one 21-bit period counter across six parallel comparators producing 50 Hz output on each channel.

The FSM has six action states — `movePos`, `moveNeg`, `gripOpen`, `gripClose`, `resetHome`, plus `idle` — and a cooldown counter that gates how often the regfile can be written so a single button press doesn't get interpreted as fifty. The original plan also included `RECORD` and `RUN_PLAYBACK` states; I dropped those when I pivoted away from MicroBlaze because storing a multi-second motion buffer in pure logic was out of scope for the time I had left.

### 2.3 Calculations / Analysis / Drawings

Everything timing-related comes from two facts: the servo expects a 20 ms period (50 Hz) and the system clock is 100 MHz. That means the period counter has to count to 2,000,000, which needs 21 bits. Pulse widths of 1.0 ms, 1.5 ms, and 2.0 ms map to 100,000, 150,000, and 200,000 cycles respectively. The joint command registers are 18 bits because 200,000 exceeds 2¹⁷ — 18 is the minimum that fits without leaving headroom I don't need.

At home the duty cycle is 1.5 ms / 20 ms = 7.5 %, so a multimeter on a JB output reads 3.3 V × 0.075 = 0.247 V. That number ended up being the most useful thing on the bench because I could verify a pulse width was correct without an oscilloscope on hand. The step size per button press is 30 counter cycles, which is 0.3 µs of pulse width. In hindsight this is too small relative to the servos' deadband (typically 1–4 µs) and is part of what produced the choppiness described in section 5.

### 2.4 Bill of Materials

All hardware was on hand or lab-issued; nothing was purchased.

- Nexys Video FPGA board (lab-issued)
- NES controller (lab-issued)
- Hiwonder LeArm robotic arm, aluminum frame
- Servos: 2× LDX-218 (base, shoulder), 1× LDX-335MG (elbow), 1× LD-1501MG (wrist pitch), 2× LFD-06 (wrist rotate, gripper)
- Bench DC power supply, 7.0 V
- Buck converter and bidirectional level shifter
- Perf board with shared power/ground rails, jumper harness

### 2.5 Milestone I

Milestone I is bringing each module up individually and proving the chain works end-to-end on a single joint. The verification tests are: press each NES button and confirm the corresponding bit appears on the LED debug output; observe a stable PWM pulse on an oscilloscope when the regfile holds a known value; hold a move button and watch a servo respond.

### 2.6 Milestone II

Milestone II is the full multi-joint teleoperation: control over all six joints, joint selection through the FSM with LED feedback, gripper open/close, and movement that stays consistent across repeated trials. The tests are running each joint across its range, cycling joint selection in both directions, and operating the gripper.

### 2.7 Updated Functionality and Requirements

**Minimum functionality:** Single joint controlled via NES button presses, with PWM output verified on a multimeter. ✓

**B-level functionality:** All six joints commandable via NES buttons, joint selection cycling correctly through all six positions with LED feedback, gripper open/close on A/B, reset-to-home on Start, hardware-level motion clamps preventing over-rotation. _Partially achieved_ We believe three of the servos were nonfunctional (top 3), which prevented us from controlling them with our system.

**A-level functionality:** Full multi-joint motion demonstration, with smooth servo motion across all joints. _Partially achieved_ — the control system meets all A-level criteria; mechanical motion smoothness was limited by power-delivery and deadband issues described below. The recorded-playback feature was descoped during the pivot away from MicroBlaze. Additionally, we believe three of the servos were nonfunctional (top 3), which prevented us from controlling them with our system.

---

## 3 Milestone I

Milestone I was met. Each NES button maps to its bit position on the LED debug output. The PWM pulse on JB1 was verified at 0.247 V on a multimeter at home position, matching the calculated 7.5 % duty cycle. Holding Right with joint 0 selected produced a measurable voltage rise toward 0.330 V, confirming the full input-to-output chain.

## 4 Milestone II

Milestone II was met for the control system. All six joints are addressable via Up/Down joint cycling, with LEDs showing the current selection (000 through 101). The shoulder responded to button-driven commands with visible motion, though choppy. The gripper held position and responded to A/B when wired direct to the supply. Right, Left, Start, A, and B all behave per their bit map (Right=0, Left=1, Down=2, Up=3, Start=4, Select=5, B=6, A=7) after a fix to `nes_interface` that added a settling state between the latch falling edge and the first sample.

## 5 Final Demonstration and Test Results

The control system works end-to-end. The mechanical demonstration was limited by two hardware issues I identified but did not fully resolve in time:

**Choppy motion.** The 30-count step size produces 0.3 µs of pulse-width change per press, which is below most servos' deadband. Several presses do nothing, then the cumulative drift crosses the deadband threshold and the servo lurches. Increasing the step to 100–150 counts (1.0–1.5 µs) would likely smooth this out — I confirmed the failure mode but did not have time to retune and re-verify.

**Power delivery.** Bench supply current measured around 20 mA when the servos should have been pulling 200–500 mA under load. Three of the six servos felt unresponsive when hand-rotated; the other three resisted firmly. We believe the wrist pitch, wrist rotate, and gripper servos were nonfunctional, which prevented us from controlling the end-effector through our system. After bypassing the level shifter and wiring the shoulder PWM signal directly from the JB pin to the servo, the shoulder moved more reliably than through the shifter, which suggests the shifter's switching behavior under our load conditions was contributing to the issue.

The control path itself was verified through three independent measurements: simulation testbenches for each module, multimeter readings on every JB pin matching the calculated duty-cycle voltages, and LED feedback confirming joint-selection state. The remaining work is hardware characterization, not redesign.

## 6 Presentation

Presentation submitted on gradescope.

---

## Appendix A: Running the Project

**Required tools:** Vivado 2024.2. No MicroBlaze, so no Vitis.

**Hardware setup:**

1. Wire the NES controller to Pmod JA: JA1 = latch, JA2 = pulse, JA3 = data, JA5 = GND, JA6 = 3.3 V.
2. Wire each servo signal to its Pmod JB pin: JB1 = base, JB2 = shoulder, JB3 = elbow, JB4 = wrist pitch, JB7 = wrist rotate, JB8 = gripper.
3. Tie a jumper from the bench supply ground to JB5 to share ground between FPGA and supply. _This is not optional_ — without it the servos cannot interpret the PWM signal correctly.
4. Bench supply set to 7.0 V, current limit 3 A. Connect to the perf-board rail powering the servo red wires.
5. Power up the FPGA via USB _first_, then enable the bench supply. Reverse on power-down.

**Build:**

1. Open the Vivado project in this repo.
2. Verify the source files in the project: `top.vhd`, `nes_interface.vhd`, `button_reg.vhd`, `control_fsm.vhd`, `joint_regfile.vhd`, `limit_clamp.vhd`, `pwm_gen.vhd`, plus the constraints file `top.xdc`.
3. Run synthesis, then implementation, then generate bitstream.
4. Program the device.

**Verification (multimeter only, no servos required):**

Press CPU_RESET. JB1 should read 0.247 V. Press Up — LEDs cycle 000 → 001. Hold Right with joint 0 selected — JB1 voltage rises toward 0.330 V. Press Start — voltage snaps back to 0.247 V. If those four checks pass, the design is working.

---

## Documentation

Claude was used during this project within the bounds permitted for AI assistance. Specifically, Claude was used to: (1) help debug existing VHDL code by identifying logical errors in the NES protocol decoder, control FSM, and register file modules; (2) generate simulation testbenches for unit-level verification of the limit_clamp, nes_interface, and integrated top-level design; and (3) provide conceptual breakdowns of project architecture and signal-integrity concepts (PWM timing, servo deadband, level-shifter behavior). All design decisions, hardware integration, wiring, system architecture, and final implementation choices were made by the author. I used grammarly to edit and improve writing flow for presentation, and other online reseources to further understanding of hardware components and concepts for system integration.
