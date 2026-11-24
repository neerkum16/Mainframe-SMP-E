# Lab Conventions

## Token mechanism

- Tokens may reference other tokens (`@@GCSI@@` contains `@@LABHLQ@@`). The script resolves nested tokens up to 5 passes.

- All JCL, REXX, MCS and sample files in the repo contain tokens of the form `@@NAME@@`.
- Values are defined once in `tools/shop.conf`.
- `tools/apply-shop.sh` copies the repo content into `build/` with tokens replaced. Repo sources stay tokenized.
- Upload files from `build/` to the mainframe. Never edit `build/` by hand.
- The script aborts if any token has no value or if any `@@` remains after substitution.

## Token table

### Environment

| Token | Meaning | Default | Constraint |
|---|---|---|---|
| `@@LABHLQ@@` | High-level qualifier for all lab datasets | `SMPLAB` | 1-8 chars; may be multi-qualifier (`USR1.SMPLAB`) if total DSN <= 44 |
| `@@USERID@@` | Lab userid | `MYUSER` | 1-7 chars |
| `@@JOBPFX@@` | Jobname prefix; jobname = prefix + 4 chars | `SMPL` | 1-4 chars |
| `@@JOBPARMS@@` | Full JOB parameter string after `JOB` keyword | `(ACCT),'SMPE LAB',CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID,REGION=0M` | Single line, <= 71 chars |
| `@@ALLOCATTR@@` | Allocation placement for new datasets | `STORCLAS=SMSSTD` | Either `STORCLAS=x[,MGMTCLAS=y][,DATACLAS=z]` or `UNIT=3390,VOL=SER=xxxxxx` |
| `@@CSIPLACE@@` | Full IDCAMS placement clause for CSI clusters | `STORAGECLASS(SMSSTD)` | Complete clause, e.g. `STORAGECLASS(x)` or `VOLUMES(VOL001)` |
| `@@ZFSROOT@@` | zFS/HFS mount path for path elements | `/u/myuser/smplab` | Absolute path |
| `@@ZFSDSN@@` | zFS aggregate name | `SMPLAB.ZFS` | Derived from LABHLQ by default |
| `@@PGMRNAME@@` | Programmer name in job card text | `SMPE LAB` | <= 20 chars |

### Zones and CSIs

| Token | Meaning | Default |
|---|---|---|
| `@@GZONE@@` | Global zone name | `GLOBAL` |
| `@@TZ1@@` | Target zone 1 | `TGT1` |
| `@@DZ1@@` | Distribution zone 1 | `DLB1` |
| `@@TZ2@@` | Target zone 2 (cross-zone labs) | `TGT2` |
| `@@DZ2@@` | Distribution zone 2 | `DLB2` |
| `@@ZSET1@@` | ZONESET name | `ZSET1` |
| `@@GCSI@@` | Global CSI DSN | `@@LABHLQ@@.GLOBAL.CSI` |
| `@@TCSI1@@` | Target CSI 1 DSN | `@@LABHLQ@@.TGT1.CSI` |
| `@@DCSI1@@` | Dist CSI 1 DSN | `@@LABHLQ@@.DLB1.CSI` |
| `@@TCSI2@@` | Target CSI 2 DSN | `@@LABHLQ@@.TGT2.CSI` |
| `@@DCSI2@@` | Dist CSI 2 DSN | `@@LABHLQ@@.DLB2.CSI` |

Zone names are case-insensitive in SMP/E commands but stored uppercase. Names are 1-7 chars.

### Sample product (fictitious)

| Token | Meaning | Default |
|---|---|---|
| `@@PRODQ@@` | 3-char product qualifier used in library names | `XYZ` |
| `@@FMID1@@` | Base function | `HXYZ110` |
| `@@FMID2@@` | Dependent function | `JXYZ111` |
| `@@FMID3@@` | Second product for cross-product labs | `HABC100` |
| `@@PTF01@@` ... `@@PTF20@@` | Sample PTF numbers | `UXY0001` ... `UXY0020` |
| `@@APAR01@@` ... `@@APAR05@@` | Sample APAR numbers | `AXY0001` ... |
| `@@USERMOD01@@` | Sample USERMOD | `UM00001` |
| `@@SRCID01@@` | Sample SOURCEID | `LABSRC1` |
| `@@HOLDRSN01@@` | Sample HOLD reason ID | `LABHLD1` |

Fictitious FMIDs and PTF numbers must not collide with real IBM identifiers. Verify before use.

## Dataset naming standard

Pattern: `@@LABHLQ@@.<role>.<qualifier>`

### SMP/E control datasets

| DDNAME | Dataset |
|---|---|
| SMPPTS | `@@LABHLQ@@.GLOBAL.SMPPTS` |
| SMPLOG | `@@LABHLQ@@.GLOBAL.SMPLOG` |
| SMPLOGA | `@@LABHLQ@@.GLOBAL.SMPLOGA` |
| SMPSCDS | `@@LABHLQ@@.<zone>.SMPSCDS` |
| SMPMTS | `@@LABHLQ@@.<zone>.SMPMTS` |
| SMPSTS | `@@LABHLQ@@.<zone>.SMPSTS` |
| SMPLTS | `@@LABHLQ@@.<zone>.SMPLTS` |
| SMPTLIB | `@@LABHLQ@@.<zone>.SMPTLIB` |
| SMPWRK1-6 | Temporary, DSN assigned in JCL, `DISP=(NEW,DELETE)` |
| SMPOUT, SMPRPT, SMPLIST | SYSOUT or temp datasets |

`<zone>` is the zone name (`TGT1`, `DLB1`, ...). MTS, STS, LTS, SCDS are per target zone; SMPTLIB per global zone usage as RFDSNPFX dictates (VERIFY in M01 chapter).

### Product libraries

| Type | Pattern | Example |
|---|---|---|
| Target (S-prefix) | `@@LABHLQ@@.S@@PRODQ@@<type>` | `SMPLAB.SXYZLOAD`, `SMPLAB.SXYZMAC` |
| Distribution (A-prefix) | `@@LABHLQ@@.A@@PRODQ@@<type>` | `SMPLAB.AXYZLOAD`, `SMPLAB.AXYZMAC` |
| Second product | same pattern with `@@FMID3@@` qualifier mapping | `SMPLAB.SABCLOAD` |
| Work/temporary | `@@LABHLQ@@.WORK.<purpose>` | `SMPLAB.WORK.RELFILE` |
| Backup | `@@LABHLQ@@.BACKUP.<date>` | `SMPLAB.BACKUP.D260101` |
| Exercise input | `@@LABHLQ@@.INPUT.<purpose>` | `SMPLAB.INPUT.HOLDDATA` |

`<type>` values: `LOAD`, `MAC`, `SRC`, `MOD`, `DATA`, `PARM`, `PROC`, `CLIST`, `SAMP`.

## File naming standard

| Item | Pattern | Example |
|---|---|---|
| JCL | `MMEE-purpose.jcl` | `0305-receive-holddata.jcl` |
| REXX | `MMEE-purpose.rexx` | `0801-parse-holds.rexx` |
| Sample MCS | `<type>-<id>.mcs` | `function-@@FMID1@@.mcs` (token resolved at build) |
| Sample output | `MMEE-purpose.out` | `0305-receive-holddata.out` |
| Exercise doc | `exercises/MM-EE-title.md` | `exercises/03-05-receive-holddata.md` |

MM = module, EE = exercise sequence within module.

## Mainframe member naming (upload)

| Repo file | PDS member | PDS |
|---|---|---|
| `jcl/MMEE-*.jcl` | `JMMEE` | `@@LABHLQ@@.JCL` |
| `rexx/MMEE-*.rexx` | `RMMEE` | `@@LABHLQ@@.REXX` |
| `shared/sample-sysmods/*` | by manifest | `@@LABHLQ@@.INPUT.*` |

The upload mapping is defined in `tools/upload-map.txt` (created in M00).

## Job card

Every JCL file begins:

```
//@@JOBPFX@@MMEE JOB @@JOBPARMS@@
```

Jobname length = length(`@@JOBPFX@@`) + 4 <= 8.

## Recorded after first run (fill in)

| Item | Value |
|---|---|
| z/OS level | 3.2 |
| SMP/E level (from SMPOUT header) | VERIFY |
| RFDSNPFX | VERIFY |
| LPAR / sandbox type | (do not commit) |
| Date captured | |

## Isolation rules

- Lab CSIs are never shared with the running system's SMP/E zones.
- Lab datasets are not placed under `SYS1.*` or any production HLQ.
- GIMSMP is invoked with `PGM=GIMSMP` from the system link list. Do not point lab jobs at the production global zone.
- Verify `@@LABHLQ@@` does not match any existing catalog alias or RACF profile that grants unintended access.