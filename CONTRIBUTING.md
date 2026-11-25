# Contributing

## Branches and pull requests

- Work on a branch per module: `m02-receive`, `m03-apply`, and so on.
- Open one pull request per module into `main`.
- Do not commit generated output (`dist/`) or client material (`host_on_demand_contents.md`).

## Before opening a pull request

Run all four checks and commit the regenerated `coverage-matrix.md`:

```
python tools/check_code.py
python tools/check_coverage.py --write
python tools/check_mermaid.py
python tools/build.py
```

## Pull request checklist

- [ ] The article front matter lists every curriculum sub-topic verbatim, in order.
- [ ] There is one H2 per sub-topic and the matrix has no MISSING row.
- [ ] Every code file is listed in `labs/manifest.json` with `verified: false` unless it was run on z/OS.
- [ ] JCL, MCS and SMP/E commands were checked against the Commands and Reference books for the release named in `smpe_release`.
- [ ] Each lab has expected results and a rollback path.
- [ ] Sources are in the front matter with the release each was checked against.
- [ ] No emoji, no filler, no appendices.

## Recording verification

When a code file has been run on z/OS, change only its manifest entry: set `verified` to `true` and fill `verified_on`, `verified_by` and `zos_release`. Add the matching SMPOUT excerpt to `labs/expected/`. Use a separate commit.

## Code files

- ASCII only, no tabs, 80 columns maximum.
- File name `MNNLNN-MEMBER.ext` for lab code or `MEMBER.ext` for shared code.
- `.mcs` files are SYSMOD packages for `SMPPTFIN`. Do not add comment lines to them: every line is either MCS or element text.
