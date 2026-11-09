# Data of station O-CLIMBOX 03

Station O-CLIMBOX 03 was installed at a freshwater fish pond of the Faculty of Fisheries
and Marine Sciences, Universitas Padjadjaran, Jatinangor, West Java, Indonesia.

| File | Content |
|---|---|
| `station03_readings_2026-09-21_2026-10-09.csv` | All records received by the server, one every 5 s while the station was on (including commissioning, maintenance and short tests) |
| `station03_continuous_test_2026-09-28_2026-10-02_qc.csv` | Continuous operation test (28 Sep 2026 17:24 to 2 Oct 2026 13:06 WIB, Section 7.2 and Table 8 of the article) with QC flags from `analysis/qc.py` |

## Columns

| Column | Unit | Notes |
|---|---|---|
| `id` | – | Record number in the database |
| `timestamp` | ISO 8601, WIB (UTC+7) | Assigned by the server at reception |
| `do_saturation` | % | DO saturation, relative to the pressure stored in the sensor (101.33 kPa by default) |
| `do_mgl` | mg/L | Not corrected for local barometric pressure (see Section 7.1 of the article) |
| `do_temperature` | °C | Temperature of the DO probe (water temperature) |
| `ph` | pH units | |
| `ph_temperature` | °C | Measured on the transmitter board inside the enclosure, not in the water |
| `orp` | mV | Potential of the pH electrode (no ORP electrode fitted); not a redox potential |
| `ec` | µS/cm | Compensated to 25 °C by the transmitter (2%/°C); 0 = EC electrode not immersed |
| `salinity` | mg/L | Transmitter output, EC × 0.55; not practical salinity |
| `tds` | mg/L | Transmitter output, EC × 0.50 |
| `tds_temperature` | °C | Temperature of the EC probe |
| `latitude`, `longitude` | degrees | Empty when the gateway did not report a GNSS position |
| `stasiun_id` | – | Station name |
| `*_qc` | flag | 1 pass, 3 suspect, 4 fail, 9 missing (QARTOD); highest flag of all tests of Table 6 |

Records with all sensor values equal to 0 were sent immediately after power-up.
Records with `ec` = 0 were taken while the flow cell was empty or partly filled and do not
represent the water. The flow cell was filled for 120 s per hour during the continuous test,
so most immersed records were taken in water retained between fillings.

Sensors: DFRobot SEN0681 (DO, Modbus address 1, UART1, 4800 bps), Khurslabs PHORP10
(pH/ORP, address 2, UART2, 9600 bps), Khurslabs ECTDS10-ISO (EC/salinity/TDS, address 3,
UART2, 9600 bps). Register scaling is given in Table 5 of the article.
