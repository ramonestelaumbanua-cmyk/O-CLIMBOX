# O-CLIMBOX v1.0.0 — design files, software and data

O-CLIMBOX is an open-source, solar-powered IoT multiparameter water quality station
for shallow coastal waters. A pump draws water into a flow cell where dissolved oxygen
(DO), pH, electrical conductivity (EC, with derived salinity and TDS) and temperature are
measured over RS485 Modbus; a second pump rinses the probes with fresh water. A 4G LTE
edge gateway (USR-M100) publishes the readings over MQTT to a Node-RED server with a
MySQL database and a web portal, which also schedules the pumps and sends remote
calibration commands that are confirmed by the sensors.

This archive accompanies the article:

> N.P. Purba, R.T. Banua, S. Ismaulanie, P.P. Kelana, A.R. Azhar, L.P. Dewanti, G.B. Pratama,
> O-CLIMBOX: An open-source IoT multiparameter water quality station with automated sampling
> and freshwater rinsing for coastal waters, HardwareX (submitted).

Development mirror: https://github.com/ramonestelaumbanua-cmyk/O-CLIMBOX

## Contents

| Path | Description | License |
|---|---|---|
| `hardware/3d-print/battery_holder_large_battery_box.stl` | Battery holder (Table 3: "Battery holder") | CC BY 4.0 |
| `hardware/3d-print/module_housing_large_module_box.stl` | Module housing that holds the gateway (Table 3: "Module housing") | CC BY 4.0 |
| `hardware/3d-print/pump_housing_large_pump_box.stl` | Pump housing (Table 3: "Pump housing") | CC BY 4.0 |
| `hardware/3d-print/sensor_tube_layer_water_box.stl` | Sensor tube / water box of the flow cell (Table 3: "Sensor tube") | CC BY 4.0 |
| `hardware/electrical/wiring_diagram.pdf` | Wiring diagram of sensors, gateway, pumps and power supply | CC BY 4.0 |
| `hardware/electrical/system_architecture.png` | System architecture (Fig. 2 of the article) | CC BY 4.0 |
| `hardware/bill_of_materials.csv` | Bill of materials (Section 4 of the article), USD at IDR 17,891.40/USD, October 2026 | CC BY 4.0 |
| `software/node-red/oclimbox_flow.json` | Node-RED flow: MQTT ingestion, unit conversion, MySQL storage, pump scheduler, Modbus frames for pumps and calibration, REST API with JWT access control, audit log | GPL-3.0 |
| `software/portal/portal.html` | Web portal (content of the `/portal` template node) | GPL-3.0 |
| `software/database/schema.sql` | MySQL schema (stations, readings, jadwal_pompa, users, station_members, audit_log) | MIT |
| `analysis/qc.py` | QARTOD-based QC tests of Table 6 of the article | MIT |
| `data/` | Readings of station O-CLIMBOX 03 and the QC-flagged continuous test (see `data/README.md`) | CC BY 4.0 |

Print settings: PLA (PETG or ASA recommended for long coastal deployments), 0.2 mm layer
height, 15% gyroid infill; see Table 3 of the article.

## Quick start (server)

1. Install Mosquitto, MySQL and Node-RED on a server, add the Node-RED palette
   `node-red-node-mysql` (and `node-red-dashboard` for the legacy dashboard tab), install
   `jsonwebtoken` and a bcrypt module (`bcryptjs` or `bcrypt`) in the Node-RED user directory
   and expose them to function nodes in `settings.js`:
   `functionGlobalContext: { jwt: require('jsonwebtoken'), bcrypt: require('bcryptjs') }`.
2. Create the database with `software/database/schema.sql`.
3. Set the environment variable `JWT_SECRET` for Node-RED (secrets are not stored in the flow),
   import `software/node-red/oclimbox_flow.json`, enter the MySQL credentials in the
   MySQLdatabase configuration node and deploy.
4. Add one row per station to the `stations` table (MQTT topics and Modbus addresses) and
   configure the USR-M100 gateway as described in Section 6.1 of the article.

For deployment, protect the MQTT broker with authentication and TLS (port 8883) and serve
the portal over HTTPS only.

## Licenses

See `LICENSE.md`. Hardware design files and data: CC BY 4.0. Node-RED flow and web portal:
GNU GPL v3. Database schema and analysis script: MIT.

## How to cite

Cite the article and this archive: https://doi.org/10.5281/zenodo.23804672 (see `CITATION.cff`).
