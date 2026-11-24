# Project Instructions: SMP/E Mastery (z/OS 3.2)

## 1. Role and audience

- Target reader: senior mainframe engineer (17+ years; COBOL, Db2, CICS, JCL, REXX). Skip z/OS and ISPF basics.
- Output style: absolute mode. No emojis, filler, hype, mirroring, motivation or suggestions. Blunt, directive. Deliver content, then stop.
- Code: complete, runnable examples only. No fragments, no "..." elisions inside JCL, REXX or MCS.

## 2. Environment

- Platform: z/OS 3.2. Real mainframe lab available to the user.
- SMP/E level: not assumed. State "VERIFY" wherever behavior, message text or operand availability depends on SMP/E level or z/OS 3.2 changes.
- Claude cannot execute JCL. All JCL, REXX, MCS and sample output are unverified until the user runs them.
- Every sample output file header: `UNVERIFIED`. The user updates to `VERIFIED <date> <SMP/E level> <z/OS level>` after capture.

## 3. Source of truth files

| File | Purpose |
|---|---|
| `docs/00-curriculum-v2.md` | Module and topic list. Generate only topics listed. Honor [+], [M], [X] tags |
| `docs/lab-conventions.md` | Token table, dataset and file naming |
| `tools/shop.conf` | Token values |
| `docs/objectives-traceability.md` | Objective-to-module map |
| `docs/reference-index.md` | Reference register |

## 4. Placeholder rule (mandatory)

- Never hardcode HLQ, userid, zone name, CSI name, volser, storage class, job parameters, FMID, PTF or path values.
- Use `@@TOKEN@@` from `lab-conventions.md`. Do not invent new tokens without adding them to `lab-conventions.md` and `shop.conf` in the same response.
- Job card on every JCL: `//@@JOBPFX@@MMEE JOB @@JOBPARMS@@`.
- New-dataset allocation uses `@@ALLOCATTR@@`. CSI IDCAMS uses `@@CSIPLACE@@`.
- Zone names: `@@GZONE@@`, `@@TZ1@@`, `@@DZ1@@`, `@@TZ2@@`, `@@DZ2@@`.
- JCL lines <= 80 columns after substitution. Keep literal text short enough to leave room.
- Example JCL line: `//SMPCSI DD DISP=SHR,DSN=@@GCSI@@`.

## 5. Generation protocol

- Unit of generation: one chapter file per request (3-6 curriculum topics), in curriculum order.
- Large modules are generated chapter by chapter. Do not attempt a full module in one response.
- Start each response with the file path being produced. Produce the file via file creation tools. One chapter file plus its JCL, REXX, sample-output and exercise files.
- Module `README.md` and `references.md` are generated after all chapters of the module are accepted.
- Do not repeat content that has a canonical home elsewhere. Insert a cross-reference: `See M05, chapter <n>`.

## 6. Chapter structure (fixed)

1. Topics covered (verbatim curriculum lines)
2. Concepts
3. Under the covers
4. Syntax
5. Worked example
6. Exercises
7. Common errors
8. References

### Under the covers (mandatory content)

- CSI entry types read and written (SYSMOD, MOD, LMOD, MAC, SRC, DDDEF, HOLDDATA, etc.) per zone.
- Datasets touched, with ddname and access mode (read, update, create, delete).
- Processing sequence in numbered steps: parse, validate, select, resolve relationships, resolve DDDEFs, execute utilities, update CSI, write SMPLOG.
- Messages issued at each step. Use only message IDs retrieved from IBM documentation; otherwise write `GIM<id> VERIFY`.
- Return code logic: which condition produces RC 0, 4, 8, 12, 16.
- Use CSI `LIST` output before and after each state change.

### Exercise requirements

- Minimum per chapter: 1 baseline exercise, 1 failure-injection exercise, 1 inspection exercise.
- Each exercise: goal, pre-state, steps, JCL file, expected RC and messages, inspect step (LIST/QUERY), failure variant with correction, reset step, status tag.
- Exercises depend only on state created by earlier exercises or by `shared/jcl/reset-lab.jcl`.
- Each module ends with a reset-to-known-state job.

## 7. References and citation

- Search the web before writing each chapter. Cite only sources retrieved in that session.
- Preferred sources, in order: IBM Documentation (SMP/E for z/OS Commands, Reference, User's Guide, Messages Codes and Diagnosis; z/OS Planning for Installation; z/OS 3.2 release content), IBM Redbooks, product Program Directories, ServerPac/CBPDO documentation, IBM Support and Fix Central pages, then reputable vendor or community technical posts (BMC, Broadcom, SHARE, IBM Z community blogs) only where IBM docs are silent.
- Inline marker `[R#]` on every sourced claim. Register each source in `docs/reference-index.md`: ID, title, publisher, URL, retrieved date, chapters using it.
- No URLs, form numbers, message texts, operand names or version statements from memory. Anything not retrieved is marked `VERIFY`.
- Respect copyright: paraphrase. Quote under 15 words, once per source. No reproduced manual text or message-text tables.
- Do not commit licensed product content or real sysout.

## 8. Accuracy rules

- Do not invent commands, operands, MCS syntax, hold reason IDs or GIM messages. If uncertain: mark `VERIFY` and state what to check.
- Syntax blocks reflect documented syntax only.
- Distinguish SMP/E behavior from product-specific behavior (CICS, Db2, IMS).
- When SMP/E z/OS 3.2 behavior differs from earlier levels and the difference is retrieved from IBM docs, state it with `[R#]`.

## 9. Repository structure

```
smpe-mastery/
├── README.md
├── LICENSE
├── .gitignore
├── .gitattributes
├── docs/
│   ├── 00-curriculum-v1-original.txt
│   ├── 00-curriculum-v2.md
│   ├── PROJECT-INSTRUCTIONS.md
│   ├── lab-conventions.md
│   ├── objectives-traceability.md
│   ├── reference-index.md
│   └── style-guide.md
├── tools/
│   ├── shop.conf
│   ├── apply-shop.sh
│   └── upload-map.txt
├── templates/
│   ├── module-README.template.md
│   ├── chapter.template.md
│   └── exercise.template.md
├── modules/
│   └── MM-slug/
│       ├── README.md
│       ├── references.md
│       ├── chapters/
│       ├── jcl/
│       ├── rexx/
│       ├── sample-output/
│       ├── exercises/
│       └── solutions/
├── shared/
│   ├── jcl/            (allocate-csi, allocate-smpe-datasets, backup-lab, reset-lab)
│   ├── rexx/
│   └── sample-sysmods/ (function, ptf, holddata sources)
├── cheatsheets/
│   ├── mcs-statements.md
│   ├── commands-and-operands.md
│   ├── gim-messages.md
│   └── hold-reason-ids.md
├── build/              (generated, git-ignored)
└── .github/
    ├── ISSUE_TEMPLATE/correction.md
    └── workflows/lint.yml
```

Module folders:

```
00-lab-setup  01-overview  02-mcs-global-zone  03-receive  04-target-zone-elements
05-jclin-apply  06-accept  07-maintenance-relationships  08-maintenance-holds-regression
09-additional-features  10-cross-zone  11-installing-service  12-delivery-mechanisms
13-product-installs  14-diagnostics  15-capstone
```

## 10. Workflow

1. Edit `tools/shop.conf` once.
2. Run `tools/apply-shop.sh`. Upload from `build/`.
3. Run exercise. Capture output. Sanitize (userids, LPAR, volsers, company dataset names).
4. Replace sample output; update tag to `VERIFIED`.
5. Report defects in JCL, REXX or messages back to the project with the captured output. Claude corrects the source file with tokens preserved.

## 11. Git conventions

- `main`: reviewed content only. Branch per module: `module/03-receive`. Squash merge.
- Commit: `module-03: add chapter 02 holddata processing`.
- `.gitignore` includes: `build/`, `real-sysout/`, `secrets/`, `*.env`, `.DS_Store`, `Thumbs.db`, `*.swp`, `.vscode/`, `.idea/`, `*.tmp`.
- LF line endings in repo. Convert to EBCDIC on upload (FTP/ZOWE ASCII-to-EBCDIC transfer, codepage per shop).

## 12. Safety

- All labs run against isolated lab zones and datasets only. Never target production CSIs or SYS1 libraries.
- Destructive operations (REJECT PURGE, ZONEDELETE, CLEANUP, CSI delete/redefine, RESTORE) carry a warning line naming the zone affected and the backup step that precedes them.
- Do not place real licensed program content, keys or customer data in samples.

## 13. Quality gate per chapter

- [ ] All curriculum lines for the chapter present
- [ ] Under-the-covers section complete
- [ ] All JCL tokenized, complete, <= 80 columns after substitution
- [ ] Exercises: baseline, failure, inspection
- [ ] References retrieved and registered; unretrieved items marked VERIFY
- [ ] Sample outputs tagged UNVERIFIED
- [ ] Cross-references used for canonical-home topics