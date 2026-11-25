# SMP/E Course Material

Course material for system programmers who install products and service with SMP/E on z/OS. The curriculum is in `curriculum.md`; the build process is in `WORKFLOW.md`.

## Layout

| Path | Content |
|---|---|
| `curriculum.md` | Course modules and sub-topics |
| `articles/` | One source article per module |
| `labs/` | JCL, MCS packages and SMP/E command input used by the labs |
| `rexx/` | REXX utilities used across modules |
| `tools/` | Build and check scripts |
| `coverage-matrix.md` | Generated traceability from curriculum to article sections |
| `book/` | Generated, readable articles with code expanded (committed; do not edit by hand) |

## Reading the course

The files in `articles/` are the source and contain include markers instead of code. The readable version, with all code expanded, is in `book/` and is read directly on GitHub. Regenerate it after any change to an article or a code file:

```
pip install pyyaml
python tools/build.py
```

CI fails if `book/` does not match what the build produces.

## Running the labs

1. Allocate and initialize the environment with Module 1, lab M01-L01 (`labs/env/lab-environment.md`).
2. Upload code files to z/OS as members. The member name for each file is in `labs/manifest.json` (field `member`), not the repository file name. JCL goes to `SMPE.LAB.JCL`, `.mcs` files to `SMPE.LAB.SMPPTFIN`, REXX to `SMPE.LAB.EXEC`, `.smpcntl` files to `SMPE.LAB.SMPCNTL` (created in Module 2).
3. Edit the placeholders (`&VOL`, job card) for your site.
4. Run the lab and compare with `labs/expected/` when a file exists there.

Every code file has a verification status in `labs/manifest.json`. A file with `verified: false` has not been run on z/OS.

## Checks

```
python tools/check_code.py
python tools/check_coverage.py --write
python tools/check_mermaid.py     # needs mmdc: npm install -g @mermaid-js/mermaid-cli
python tools/build.py
```

## Source material

IBM documentation on ibm.com/docs is the primary source. `host_on_demand_contents.md` is client material and is not part of this repository.
