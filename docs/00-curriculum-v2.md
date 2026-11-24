# SMP/E Curriculum v2

Target: z/OS 3.2. SMP/E level: record in `docs/lab-conventions.md` after first run (VERIFY).

## Legend

| Tag | Meaning |
|---|---|
| (none) | Topic from original curriculum, typo corrected |
| [+] | Added topic (gap vs. objectives or missing from v1) |
| [M] | Moved from a different v1 module |
| [X] | Cross-reference only. Canonical coverage is in the named module |

## Change log v1 to v2

| # | Change |
|---|---|
| 1 | Typos corrected: "tTe RECEIVE command", "IProduct function" |
| 2 | Duplicates resolved. Canonical homes: macro library concatenation = M05; sysmod installation via dialogs = M05; element service level = M07; exception sysmods: received state = M03, resolution = M08 |
| 3 | Descriptive MCS and product/feature entries moved from v1-M6 to M02 |
| 4 | Modules 2, 3, 5, 6, 7 split. 7 v1 modules became 16 |
| 5 | Added: lab setup (M00), delivery mechanisms (M12), product installs (M13), diagnostics (M14), capstone (M15) |
| 6 | Added missing MCS, commands, operands, datasets, modern tooling (see [+] tags) |
| 7 | Cross-zone expanded into a dedicated module (M10) |

## Module map

| M | Title | v1 origin |
|---|---|---|
| 00 | Lab Setup | new |
| 01 | SMP/E Overview and Architecture | v1-M1 |
| 02 | MCS and Global Zone Configuration | v1-M2 part 1 |
| 03 | RECEIVE Processing | v1-M2 part 2 |
| 04 | Target Zone and Element Definitions | v1-M3 part 1 |
| 05 | JCLIN and APPLY Processing | v1-M3 part 2 |
| 06 | ACCEPT Processing | v1-M4 |
| 07 | Maintenance: Sysmods, Relationships, Service Level | v1-M5 part 1 |
| 08 | Maintenance: Holds, Exposure, Regression, RESTORE, REJECT | v1-M5 part 2 |
| 09 | Additional Features: CALLIBS, Zone Management, GENERATE, CLEANUP | v1-M6 part 1 |
| 10 | Cross-Zone and Cross-Product Processing | v1-M6 part 2 |
| 11 | Installing Service: Problems, Preparation, PSP, FIXCAT | v1-M7 part 1 |
| 12 | Delivery Mechanisms | v1-M7 part 2 |
| 13 | Product Installs: CICS, Db2, IMS | new |
| 14 | Diagnostics and Problem Resolution | new |
| 15 | Capstone | new |

---

## M00 Lab Setup [+]

- [+] Lab isolation rules: no shared or production CSIs, no production SMP/E libraries
- [+] Token substitution workflow (`tools/shop.conf`, `tools/apply-shop.sh`)
- [+] Naming convention and placeholder table
- [+] Allocation of GLOBAL, TARGET, DLIB CSIs (IDCAMS) and zone initialization
- [+] Allocation of SMPPTS, SMPLOG, SMPLOGA, SMPSCDS, SMPMTS, SMPSTS, SMPLTS, SMPWRK1-6, SMPTLIB
- [+] zFS for path elements
- [+] Fictitious sample product (FMID, PTFs, HOLDDATA) build as relative-file input
- [+] Backup and reset procedure (DFSMSdss DUMP/RESTORE of lab HLQ)
- [+] Recording SMP/E and z/OS level; ENQ and concurrency notes

## M01 SMP/E Overview and Architecture

- What is 'System Modification Program Extended'?
- What makes a product?
- SMP/E elements
- How products are packaged
- System modifications
- SMP/E database
- Receiving a SYSMOD
- Applying, accepting and restoring a SYSMOD
- System Generation
- Consolidated Software Inventory
- CSI configuration option
- Invoking SMP/E
- [+] Three-zone model: GLOBAL, TARGET, DLIB. Zone sets
- [+] SMP/E datasets: SMPPTS, SMPSCDS, SMPMTS, SMPSTS, SMPLTS, SMPLOG, SMPLOGA, SMPOUT, SMPRPT, SMPLIST, SMPWRK1-6, SMPTLIB. Purpose, lifecycle, space
- [+] Invocation: GIMSMP batch, ISPF dialogs, GIMAPI, REXX/APIs
- [+] Basic commands: SET BOUNDARY, LIST, QUERY. Output reading basics
- [+] SMP/E level and z/OS 3.2 specifics (VERIFY against retrieved docs)

## M02 MCS and Global Zone Configuration

- Modification Control Statements
- MCS: header statement functions, software environment statement
- The Global Zone definition entry
- GZONE entry example
- Global Zone options entry
- options entry example
- Global Zone utility entry
- Utility entry example
- SMP/E allocation
- Global Zone DDDEF entry
- DDDEF entry example
- Review of Global Zone entries
- Creating Global Zone entries – UCLIN
- [M] Descriptive MCS statements (++FEATURE, ++PRODUCT)
- [M] Product and feature entries
- [+] SET BOUNDARY, UCLIN/ZONEEDIT, ADD/REP/DEL/UCLIN CLEAR semantics
- [+] ZONESET entries
- [+] Complete MCS inventory: ++ASSIGN, ++HOLD, ++IF, ++MOVE, ++RENAME, ++DELETE, ++JAR, ++JARUPD, ++PROGRAM, ++HFS, ++PATH variants, ++ZFS (syntax overview; element specifics in M04)

## M03 RECEIVE Processing

- The RECEIVE process
- Relative file packaged tapes
- Receive processing
- Global Zone sysmod entry example
- Exception sysmods (received state: HOLD, ERROR, SYSTEM, USER)
- Held sysmod entry example
- Holddata example
- The RECEIVE command
- Sysmod entry with SOURCEID example
- REPORT SOURCEID output examples
- SMP/E dialogs primary option menu & query selection menus
- [+] RECEIVE operands: SYSMOD, HOLDDATA, FORFMID, SOURCEID, EXCLUDE, SELECT, LIST, FROMDS, TARGETZONE, FIXCAT
- [+] ++ASSIGN and ++HOLD statements
- [+] RECEIVE ORDER (z/OSMF-assisted download) and GIMZIP/GIMUNZIP package handling
- [+] Enhanced HOLDDATA (full and delta), HOLDDATA ingestion workflow
- [+] SMPPTS content and space under RECEIVE; REJECT PURGE preview [X]M08
- [+] GIMXSID utility (VERIFY scope in retrieved doc)

## M04 Target Zone and Element Definitions

- Product function & installation methods
- Target Zone definition entry
- TZONE entry example
- Target Zone DDDEF entry
- Target Zone DDDEF entry example
- Target Zone DDDEF PATH entry
- Target Zone DDDEF PATH entry example
- MAC, SRC, and MOD element MCS
- Data Element MCS
- Program Element MCS
- Identifying the target system structure
- [+] Element MCS completeness: ++MACUPD, ++SRCUPD, ++MODVER, ++JAR, ++JARUPD, ++PROGRAM, ++HFS, ++ZFS, ++MOVE, ++RENAME, ++DELETE
- [+] Distribution and target library mapping (DISTLIB, SYSLIB, LMOD relationships)
- [+] DDDEF resolution order and failure modes

## M05 JCLIN and APPLY Processing

- How JCLIN processing works
- JCLIN processing example
- JCLIN report example
- JCLIN - MAC and ASSEM entries
- JCLIN - MOD and LMOD entries
- JCLIN - DLIB entries
- Invoking JCLIN
- The save control dataset
- Determining target libraries
- Apply processing
- Concatenating macro libraries for assemblies (canonical)
- SYSLIB DDDEF example
- The APPLY command
- Target Zone SYSMOD entry example
- Target Zone MAC and SRC element entries
- Target Zone MOD and DATA element entries
- Base and dependent functions revisited
- Replacing an existing product
- Sysmod installation via the SMP/E dialogs (canonical)
- SMP/E dialogs - sysmod management options
- [X] Element service level: see M07
- [+] APPLY operands: CHECK, SELECT, EXCLUDE, SOURCEID, GROUP, GROUPEXTEND, FORFMID, BYPASS, REDO, RETRY, COMPRESS, NOAPPLYCHECK (VERIFY operand names)
- [+] APPLY CHECK-first workflow and return code semantics
- [+] SMPSCDS contents and role in later RESTORE

## M06 ACCEPT Processing

- Function installation methods
- Distribution Zone definition entry
- DZONE entry example
- Distribution Zone DDDEF entries
- Distribution Zone DDDEF entry example
- ACCEPT processing
- The ACCEPT command
- Distribution Zone SYSMOD entry example
- Distribution Zone MAC and SRC element entries
- Distribution Zone MOD and DATA element entries
- [X] Concatenating macro libraries for assemblies: see M05
- [X] Sysmod installation via the SMP/E dialogs: see M05
- [X] SMP/E dialogs - sysmod management options: see M05
- [+] ACCEPT operands: CHECK, GROUP, GROUPEXTEND, COMPRESS, BYPASS, NOAPPLY, PURGE
- [+] ACCEPT of unapplied PTFs, pre-accept validation, SMPPTS removal after ACCEPT
- [+] ACCEPT and RESTORE interaction (no restore after accept)

## M07 Maintenance: Sysmods, Relationships, Service Level

- Product maintenance (service)
- product maintenance sysmods
- product maintenance sysmod naming convention
- product maintenance ++VER statement
- Updating MAC and SRC elements
- Updating MOD (and LMOD) elements
- Sysmod relationships
- The prerequisite relationship
- The requisite relationship
- The supersede relationship
- The negative prerequisite relationship
- TZONE sysmod entries – examples
- Related APPLY command parameters
- Element service level (canonical)
- Tracking the service level of an element
- Element entries - service level
- [+] Sysmod types: PTF, APAR, USERMOD, FUNCTION. Construction and ++VER/++PRE/++REQ/++SUP/++IF/++DELETE
- [+] LIST SYSMODS, LIST MODS, LIST MACS, REPORT SYSMODS, REPORT ERRSYSMODS preview
- [+] Missing PRE/REQ resolution via GROUP and GROUPEXTEND

## M08 Maintenance: Holds, Exposure, Regression, RESTORE, REJECT

- Exception sysmods (resolution)
- Resolving error holds
- Resolving system holds
- The RELEASE MCS statement
- Maintenance exposure
- The REPORT ERROR SYSMODS command
- Sysmod regression
- Sysmod construction rules
- Managing regression
- Restore processing
- The RESTORE command
- Sysmod relationships and restore
- Reject processing
- The REJECT command
- [X] Concatenating macro libraries for assemblies: see M05
- [+] Automatic hold resolution (BYPASS, ++RELEASE, ACCEPT/APPLY of fixing PTF) vs manual resolution
- [+] Hold reason IDs, USER holds, YES/NO hold processing
- [+] REJECT PURGE, REJECT NOFMID, REJECT SELECT, SMPPTS cleanup
- [+] REPORT ERRSYSMODS, REPORT MISSINGFIX [X]M11

## M09 Additional Features: CALLIBS, Zone Management, GENERATE, CLEANUP

- Callable services support
- Processing SYSLIB in JCLIN
- CALLIBS in LMOD element entries
- Installing LMODs that use CALLIBS
- The zone management commands
- Installing SYSGEN and SMP/E products
- The GENERATE command
- The CLEANUP command
- [+] REPORT CALLLIBS
- [+] LINK, UNLINK, COMPRESS, ZONEMERGE, ZONERENAME, ZONEEDIT, ZONECOPY, ZONEDELETE, ZONEEXPORT, ZONEIMPORT (VERIFY exact command list)
- [+] LMOD management, LINK MODULE, LINK LMODS
- [+] SMPLTS, SMPMTS, SMPSTS cleanup and space management
- [+] SMPLOG and SMPLOGA archival procedure

## M10 Cross-Zone and Cross-Product Processing

- The conditional requisite relationship (++IF)
- The REPORT CROSSZONE command
- Cross product 'borrowing' - the problem, the solution
- Cross zone 'borrowing' - the problem, the solution
- [+] ZONESET definitions and multi-zone environment (two target zones, two DLIB zones, one global)
- [+] Cross-zone operand behavior on APPLY and ACCEPT, XZ-related BYPASS operands (VERIFY names)
- [+] Cross-zone requisite handling: missing PRE/REQ/IF across zones, resolving with SOURCEID and GROUP
- [+] Multi-zone lab: install a PTF with an ++IF dependency on an FMID in a second target zone

## M11 Installing Service: Problems, Preparation, PSP, FIXCAT

- Reporting problems to the vendor
- Preparing for installation
- Installing maintenance
- PSP buckets
- HOLD FIXCAT
- Fix Categories
- Receiving FIXCAT HOLDs
- APPLY / ACCEPT FIXCAT operand
- REPORT MISSINGFIX command
- [+] Service installation workflow: RECEIVE ORDER, RECEIVE HOLDDATA, APPLY CHECK, APPLY, ACCEPT CHECK, ACCEPT
- [+] APAR and PTF lifecycle, PUT/RSU levels, SOURCEID conventions (RSUyymm, PUTyymm)
- [+] Backup and fallback strategy before service install

## M12 Delivery Mechanisms

- Product delivery mechanisms used by IBM
- CustomPac service
- The Recommended Service Upgrade
- ShopzSeries
- [+] ServerPac: contents, CustomPac dialog, installation JCL, SMP/E-managed content
- [+] CBPDO: contents, program directories, installation flow
- [+] ESO (Expanded Service Option)
- [+] SystemPac and ProductPac (VERIFY current availability)
- [+] z/OSMF Software Management: deployment, software instance, receive and install
- [+] Selection criteria: ServerPac vs CBPDO vs ESO vs RSU

## M13 Product Installs: CICS, Db2, IMS [+]

- [+] Reading a Program Directory: FMIDs, prerequisites, DDDEFs, JCLIN, post-install steps
- [+] Generic product install sequence: RECEIVE FMIDs, JCLIN, APPLY, ACCEPT, post-SMP/E configuration
- [+] CICS TS: FMID structure, target and DLIB zones, DFHISTAR relationship, CICS-specific holds
- [+] Db2 for z/OS: FMIDs, ++HOLD ACTION handling, DSNTIJxx post-install jobs, bind implications
- [+] IMS: FMID structure, IMS install-verification-program (IVP) relationship
- [+] Product service installation with FIXCAT
- [+] Coexistence of multiple product versions in separate zones
- Note: exercises use placeholder FMIDs and structure. Licensed content is not committed to the repo

## M14 Diagnostics and Problem Resolution [+]

- [+] GIM message anatomy: ID, severity suffix, return code mapping
- [+] Reading SMPOUT, SMPRPT, SMPLIST, SMPLOG, SMPLOGA
- [+] Common failures: DDDEF errors, space (B37, D37, E37), ENQ contention, CSI full, VSAM errors, missing PRE/REQ, JCLIN errors
- [+] Maintenance conflicts via REPORT ERRSYSMODS, REPORT SYSMODS, REPORT MISSINGFIX, REPORT CROSSZONE, REPORT CALLLIBS
- [+] Hold resolution: automatic vs manual
- [+] Recovery: restoring CSI from backup, REJECT after failed RECEIVE, zone repair with UCLIN
- [+] Fault-injection exercises with documented expected messages

## M15 Capstone [+]

- [+] End-to-end: build zones, RECEIVE function, JCLIN, APPLY, ACCEPT
- [+] Service cycle: ORDER, RECEIVE HOLDDATA, FIXCAT, APPLY CHECK, APPLY with holds
- [+] Regression and RESTORE, REJECT PURGE
- [+] Cross-zone ++IF install
- [+] Fault injection and recovery
- [+] Self-assessment mapped to all objectives