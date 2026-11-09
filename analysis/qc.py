#!/usr/bin/env python3
"""
O-CLIMBOX real-time QC tests (QARTOD-based), applied in post-processing.

Implements the tests of Table 6 of the O-CLIMBOX HardwareX article:
timing, power-up, calibration, gross range, user range, spike, flat line,
immersion (EC = 0) and redundant temperature. Each value of DO (mg/L),
DO saturation, pH, EC and the two water temperatures receives a flag
1 (pass), 3 (suspect), 4 (fail) or 9 (missing); the highest flag of all
tests is kept.

Usage:
    python qc.py readings.csv flagged.csv [--start "2026-09-28 17:24"] [--end "2026-10-02 13:06:59"]
                 [--calibration calibration_sessions.csv]

Input: CSV exported from the portal (columns timestamp, do_saturation, do_mgl,
do_temperature, ph, ph_temperature, orp, ec, salinity, tds, tds_temperature, ...).
Timestamps are local time (WIB, UTC+7). The optional calibration file has the
columns start,end (WIB) of each calibration session taken from the audit log.
User-range and spike thresholds are site-specific (here: freshwater fish pond)
and must be adapted for coastal deployments.

License: MIT
"""
import argparse
import numpy as np
import pandas as pd

PARAMS = {  # column: (gross range, user range, spike suspect/fail, flat-line suspect/fail [s])
    "do_mgl":          ((0, 20),    (0, 15),   (0.5, 1.0), (30 * 60, 60 * 60)),
    "do_saturation":   (None,       None,      None,       None),
    "ph":              ((0, 14),    (6.0, 9.5), (0.1, 0.3), (3600, 3 * 3600)),
    "ec":              ((0, 20000), (50, 1000), (50, 100),  (3 * 3600, None)),
    "do_temperature":  ((0, 60),    (18, 36),  (0.5, 1.0), (30 * 60, 60 * 60)),
    "tds_temperature": ((0, 60),    (18, 36),  (0.5, 1.0), (3600, 3 * 3600)),
}
SENSORS = ["do_saturation", "do_mgl", "do_temperature", "ph", "ph_temperature",
           "orp", "ec", "salinity", "tds", "tds_temperature"]


def parse_time(s):
    s = s.astype(str)
    # portal export: "Mon Sep 21 2026 17:36:33 GMT+0700 (...)"; data set: "2026-09-21T17:36:33+07:00"
    js = s.str.match(r"^[A-Z][a-z]{2} [A-Z][a-z]{2} \d")
    s = s.where(~js, s.str.slice(4, 24)).str.replace(r"([+-]\d\d:?\d\d|Z)$", "", regex=True)
    return pd.to_datetime(s, errors="coerce", format="mixed")  # naive local time (WIB)


def raise_flag(f, mask, level):
    return np.where(mask & (f < level), level, f)


def flat_line(x, t, susp, fail, gap=60):
    """Flag all values of a run of identical consecutive values that lasts at least
    susp (suspect) or fail (fail) seconds. A data gap longer than `gap` seconds
    (for example while the flow cell is empty) ends the run."""
    run_id = ((x != x.shift()) | (t.diff().dt.total_seconds() > gap)).cumsum()
    g = t.groupby(run_id)
    dur = (g.transform("max") - g.transform("min")).dt.total_seconds()
    f = np.ones(len(x), dtype=int)
    f = raise_flag(f, (dur >= susp).to_numpy(), 3)
    if fail:
        f = raise_flag(f, (dur >= fail).to_numpy(), 4)
    return f


def spike(x, susp, fail):
    prev, nxt = x.shift(1), x.shift(-1)
    s = (x - (prev + nxt) / 2).abs() - ((nxt - prev) / 2).abs()
    f = np.ones(len(x), dtype=int)
    f = raise_flag(f, (s > susp).to_numpy(), 3)
    return raise_flag(f, (s > fail).to_numpy(), 4)


def run_qc(d, calib=None):
    d = d.sort_values("t", kind="stable").reset_index(drop=True)
    dup = d["t"].duplicated().to_numpy()
    powerup = (d[SENSORS].fillna(0) == 0).all(axis=1).to_numpy()
    in_cal = np.zeros(len(d), dtype=bool)
    if calib is not None:
        for _, r in calib.iterrows():
            in_cal |= ((d["t"] >= r["start"]) & (d["t"] <= r["end"])).to_numpy()
    dry = (d["ec"] == 0).to_numpy()
    tdiff = (d["do_temperature"] - d["tds_temperature"]).abs().to_numpy() > 1.0

    # spike and flat-line tests use the immersed, non-duplicate, non-power-up records only
    ok = ~dup & ~powerup & ~dry
    sub = d[ok]

    for col, (gross, user, sp, fl) in PARAMS.items():
        x = d[col]
        f = np.where(x.isna(), 9, 1)
        f = raise_flag(f, dup | powerup | in_cal, 4)
        if gross:
            f = raise_flag(f, ((x < gross[0]) | (x > gross[1])).to_numpy(), 4)
        if user:
            f = raise_flag(f, ((x < user[0]) | (x > user[1])).to_numpy(), 3)
        if sp:
            fs = np.ones(len(d), dtype=int)
            fs[ok] = spike(sub[col].reset_index(drop=True), *sp)
            f = np.maximum(f, fs)
        if fl:
            ff = np.ones(len(d), dtype=int)
            ff[ok] = flat_line(sub[col].reset_index(drop=True), sub["t"].reset_index(drop=True), *fl)
            f = np.maximum(f, ff)
        f = raise_flag(f, dry, 4 if col == "ec" else 3)
        if col in ("do_temperature", "tds_temperature"):
            f = raise_flag(f, tdiff, 3)
        f = np.where(x.isna(), 9, f)
        d[col + "_qc"] = f
    return d


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("input"); ap.add_argument("output")
    ap.add_argument("--start"); ap.add_argument("--end")
    ap.add_argument("--calibration")
    a = ap.parse_args()
    d = pd.read_csv(a.input)
    d["t"] = parse_time(d["timestamp"])
    if a.start: d = d[d["t"] >= pd.Timestamp(a.start)]
    if a.end: d = d[d["t"] <= pd.Timestamp(a.end)]
    calib = None
    if a.calibration:
        calib = pd.read_csv(a.calibration, parse_dates=["start", "end"])
    q = run_qc(d, calib)
    q.drop(columns=["t"]).to_csv(a.output, index=False)
    n = len(q); imm = (q["ec"] > 0) & ~q["t"].duplicated()
    print(f"records: {n}, distinct timestamps: {q['t'].nunique()}, immersed (distinct): {imm.sum()}")
    for col in PARAMS:
        f = q.loc[imm, col + "_qc"]
        print(f"{col:16s} pass {np.mean(f == 1):6.1%}  suspect {np.mean(f == 3):6.1%}  fail {np.mean(f == 4):6.2%}  (immersed records)")


if __name__ == "__main__":
    main()
