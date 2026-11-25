# Lab Environment

All labs use one shared environment, created by Module 1 lab M01-L01.

## Names

| Item | Value |
|---|---|
| High-level qualifier | `SMPE.LAB` |
| CSI | `SMPE.LAB.CSI` (single CSI holding all three zones) |
| Global zone | `GLOBAL` |
| Target zone | `TGT1` |
| Distribution zone | `DLB1` |
| SREL | `Z038` |
| Product | XYZ, base function FMID `HXYZ110` |

## Data sets

| Data set | Organization | Created by |
|---|---|---|
| `SMPE.LAB.CSI` | VSAM KSDS | `labs/m01/jcl/M01L01-ALLOCCSI.jcl` |
| `SMPE.LAB.SMPPTS`, `SMPSCDS`, `SMPMTS`, `SMPSTS`, `SMPLTS` | PDSE | `labs/m01/jcl/M01L01-ALLOCLIB.jcl` |
| `SMPE.LAB.SXYZMAC`, `SXYZSRC` | PDSE (target libraries) | `M01L01-ALLOCLIB` |
| `SMPE.LAB.AXYZMAC`, `AXYZSRC` | PDSE (distribution libraries) | `M01L01-ALLOCLIB` |
| `SMPE.LAB.SMPPTFIN` | PDS, FB 80 (SYSMOD packages) | `M01L01-ALLOCLIB` |
| `SMPE.LAB.PROCLIB` | PDS, FB 80 (holds `SMPPROC`) | `M01L01-ALLOCLIB` |
| `SMPE.LAB.JCL` | PDS, FB 80 (lab job members from `labs/*/jcl`) | `M01L01-ALLOCLIB` |
| `SMPE.LAB.EXEC` | PDS, FB 80 (REXX members from `rexx/`) | `M01L01-ALLOCLIB` |
| `SMPE.LAB.SMPCNTL` | PDS, FB 80 (`.smpcntl` members for UCLIN input) | `M02L01-ALLOCRF` |
| `SMPE.LAB.HOLDDATA` | PDS, FB 80 (HOLDDATA members) | `M02L01-ALLOCRF` |
| `SMPE.LAB.RELFILE.HXYZ120.F1` | PDS, FB 80 (relative file for function HXYZ120) | `M02L01-ALLOCRF` |
| `SMPE.LAB.SMPTLIB*` | Created by SMP/E at RECEIVE (prefix set by OPTIONS `DSPREFIX`) | SMP/E |
| `SMPE.LAB.SMPLOG`, `SMPLOGA` | Sequential | Allocate to site standards (not created by the lab jobs) |

## Zones and DDDEFs

Zones are defined by `labs/m01/uclin/M01L01-ZONES.smpcntl`. DDDEFs are added by `labs/m01/jcl/M01L01-DDDEFS.jcl`. Work-file DDDEFs (`SMPWRK1` to `SMPWRK6`, `SYSUT1` to `SYSUT4`) are added in Module 2 by `labs/m02/uclin/M02L01-WORKDD.smpcntl`; they are needed before any RECEIVE, APPLY or ACCEPT job runs.

## Shared procedure

`labs/env/proc/SMPPROC.jcl` is copied into `SMPE.LAB.PROCLIB`. Job members use `JCLLIB ORDER=SMPE.LAB.PROCLIB`.

## Reset

To rebuild the environment, delete the data sets above and rerun M01-L01. Later modules add zones and entries to the same CSI; they state in their own prerequisites what must be reset.
