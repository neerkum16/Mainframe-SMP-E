#!/usr/bin/env python3
"""Static checks for JCL, MCS, SMP/E command and REXX files.

  - every code file is in labs/manifest.json and every manifest entry exists
  - ASCII only, no tabs, no CR, lines <= 80 columns, trailing newline
  - JCL: first line is a statement ('//'), names are <= 8 characters
  - REXX: first line is a comment containing REXX
  - member names are 1-8 characters of A-Z 0-9 @ # $
  - manifest lab ids exist in an article's front matter
  - every include marker in an article resolves to a manifest entry

These are syntax-level checks. They do not replace running the code on z/OS.
"""
import json
import re
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
EXT = {'.jcl', '.mcs', '.smpcntl', '.rexx'}
MEMBER = re.compile(r'^[A-Z0-9@#$]{1,8}$')
JCL_NAME = re.compile(r'^//([^\s]*)')
FRONT = re.compile(r'\A---\n(.*?)\n---\n', re.S)
INCLUDE = re.compile(r'^<!-- include: (\S+) -->\s*$')


def code_files():
    out = []
    for base in ('labs', 'rexx'):
        for p in (ROOT / base).rglob('*'):
            if p.is_file() and p.suffix in EXT:
                out.append(p.relative_to(ROOT).as_posix())
    return sorted(out)


def check_file(rel, errors):
    raw = (ROOT / rel).read_bytes()
    if b'\r' in raw:
        errors.append('%s: contains CR characters' % rel)
    try:
        text = raw.decode('ascii')
    except UnicodeDecodeError as e:
        errors.append('%s: non-ASCII byte at offset %d' % (rel, e.start))
        text = raw.decode('ascii', errors='replace')
    if not text.endswith('\n'):
        errors.append('%s: missing trailing newline' % rel)
    lines = text.split('\n')
    if lines and lines[-1] == '':
        lines = lines[:-1]
    if not lines:
        errors.append('%s: empty file' % rel)
        return
    for n, line in enumerate(lines, 1):
        if '\t' in line:
            errors.append('%s:%d: tab character' % (rel, n))
        if len(line) > 80:
            errors.append('%s:%d: %d columns (max 80)' % (rel, n, len(line)))
    suffix = Path(rel).suffix
    if suffix == '.jcl':
        if not lines[0].startswith('//'):
            errors.append('%s:1: JCL must start with //' % rel)
        for n, line in enumerate(lines, 1):
            if line.startswith('//') and not line.startswith('//*'):
                name = JCL_NAME.match(line).group(1)
                if any(len(part) > 8 for part in name.split('.')):
                    errors.append('%s:%d: JCL name %r has a part longer than 8' % (rel, n, name))
    if suffix == '.rexx':
        if not (lines[0].startswith('/*') and 'REXX' in lines[0]):
            errors.append('%s:1: first line must be a comment containing REXX' % rel)


def main():
    errors = []
    manifest = json.loads((ROOT / 'labs' / 'manifest.json').read_text())
    paths = [e['path'] for e in manifest]
    if len(paths) != len(set(paths)):
        errors.append('manifest: duplicate paths')
    members = {}
    lab_ids = set()
    for a in (ROOT / 'articles').glob('*.md'):
        m = FRONT.match(a.read_text())
        if m:
            for lab in (yaml.safe_load(m.group(1)).get('labs') or []):
                lab_ids.add(lab['id'])
    files = code_files()
    for rel in files:
        if rel not in paths:
            errors.append('%s: not listed in labs/manifest.json' % rel)
        else:
            check_file(rel, errors)
    for e in manifest:
        rel = e['path']
        if not (ROOT / rel).is_file():
            errors.append('manifest: %s does not exist' % rel)
        if not MEMBER.match(e['member']):
            errors.append('manifest: %s member %r is not a valid member name' % (rel, e['member']))
        if e['lab'] and e['lab'] not in lab_ids:
            errors.append('manifest: %s refers to unknown lab %s' % (rel, e['lab']))
        if e['verified'] and not (e['verified_on'] and e['verified_by'] and e['zos_release']):
            errors.append('manifest: %s is verified but lacks date, person or z/OS release' % rel)
        if not rel.startswith('labs/env/proc/'):
            members.setdefault((e['kind'], e['member']), []).append(rel)
    for key, rels in members.items():
        if len(rels) > 1:
            errors.append('manifest: %s member %s is used by more than one file: %s' % (key[0], key[1], rels))
    for a in sorted((ROOT / 'articles').glob('*.md')):
        in_fence = False
        for n, line in enumerate(a.read_text().split('\n'), 1):
            if line.startswith('```'):
                in_fence = not in_fence
            m = None if in_fence else INCLUDE.match(line)
            if m and m.group(1) not in paths:
                errors.append('%s:%d: include %s not in manifest' % (a.name, n, m.group(1)))
    if errors:
        print('\n'.join(errors), file=sys.stderr)
        return 1
    print('code ok: %d files checked' % len(files))
    return 0


if __name__ == '__main__':
    sys.exit(main())
