# ASIC Physical Design - RTL to GDSII

A complete ASIC Physical Design implementation of a dual-clock
SystemVerilog design, taken from RTL through final GDSII using
**OpenLane 2 / OpenROAD** and the **SKY130** open-source PDK.

The project covers synthesis, timing constraints, floorplanning, power
distribution, placement, clock tree synthesis, timing repair, global and
detailed routing, parasitic extraction, multi-corner static timing
analysis, physical verification, and final GDSII generation.

## Final Results

| Metric                     |            Final Result |
|----------------------------|------------------------:|
| Technology                 |                  SKY130 |
| Standard-Cell Library      |               SKY130 HD |
| Standard-Cell Instances    |                   1,838 |
| Sequential Cells           |                     333 |
| Integrated Clock Gates     |                       1 |
| Core Utilization           |                  61.06% |
| Die Area                   |            36,814.2 um² |
| Standard-Cell Area         |            18,630.4 um² |
| Worst Setup Slack          |               +2.434 ns |
| Worst Hold Slack           |               +0.088 ns |
| Setup TNS                  |                    0 ns |
| Hold TNS                   |                    0 ns |
| Setup Violations           |                       0 |
| Hold Violations            |                       0 |
| Max Slew Violations        |                       0 |
| Max Capacitance Violations |                       0 |
| Magic DRC                  |            0 violations |
| KLayout DRC                |            0 violations |
| Antenna                    |  0 net / pin violations |
| LVS                        | Circuits match uniquely |
| Layout XOR                 |           0 differences |
| Final GDSII                |               Generated |
