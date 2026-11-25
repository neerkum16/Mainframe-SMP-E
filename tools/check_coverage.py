#!/usr/bin/env python3
"""Check articles against curriculum.md and (re)generate coverage-matrix.md.

Checks per article:
  - front matter module/title/subtopics equal the curriculum entry
  - one H2 per sub-topic, in curriculum order (heading_overrides allowed in
    front matter to correct typos in the curriculum text)
  - lab headings (### Mnn-Lnn: title) equal the labs listed in front matter,
    and depends_on refers only to earlier labs

Usage: check_coverage.py [--write]
"""
import re
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
FRONT = re.compile(r'\A---\n(.*?)\n---\n', re.S)
NON_TOPIC_H2 = {'module goals', 'hands-on labs', 'review questions', 'sources'}
INCLUDE = re.compile(r'^<!-- include: (\S+) -->\s*$')


def norm(s):
    return re.sub(r'\s+', ' ', s).strip().lower()


def load_curriculum():
    mods = []
    for line in (ROOT / 'curriculum.md').read_text().split('\n'):
        if line.startswith('### '):
            mods.append({'title': line[4:].strip(), 'subtopics': []})
        elif line.startswith('- ') and mods:
            mods[-1]['subtopics'].append(line[2:].strip())
    return mods


def parse_article(path):
    text = path.read_text()
    m = FRONT.match(text)
    if not m:
        raise ValueError('%s: missing front matter' % path.name)
    meta = yaml.safe_load(m.group(1))
    body = text[m.end():].split('\n')
    sections = []  # (heading, diagrams, files, inline)
    labs = []
    in_fence = False
    fence_kind = None
    cur = None
    for line in body:
        if line.startswith('```'):
            if not in_fence:
                in_fence = True
                fence_kind = line[3:].strip()
                if cur is not None:
                    if fence_kind == 'mermaid':
                        cur['diagrams'] += 1
                    else:
                        cur['inline'] += 1
            else:
                in_fence = False
            continue
        if in_fence:
            continue
        if line.startswith('## '):
            cur = {'heading': line[3:].strip(), 'diagrams': 0, 'files': 0, 'inline': 0}
            sections.append(cur)
        elif line.startswith('### '):
            lm = re.match(r'^### (M\d\d-L\d\d): (.+)$', line)
            if lm:
                labs.append((lm.group(1), lm.group(2).strip()))
        elif INCLUDE.match(line) and cur is not None:
            cur['files'] += 1
    return meta, sections, labs


def main(write):
    errors = []
    mods = load_curriculum()
    articles = {}
    for p in sorted((ROOT / 'articles').glob('*.md')):
        meta, sections, labs = parse_article(p)
        articles[meta['module']] = (p, meta, sections, labs)

    rows = []
    for n, mod in enumerate(mods, 1):
        rows.append('## Module %d: %s\n' % (n, mod['title']))
        if n not in articles:
            rows.append('Not yet built (%d sub-topics).\n' % len(mod['subtopics']))
            continue
        p, meta, sections, labs = articles[n]
        where = p.name
        earlier_labs = {l['id'] for k, a in articles.items() if k < n for l in (a[1].get('labs') or [])}
        if meta.get('title') != mod['title']:
            errors.append('%s: title %r != curriculum %r' % (where, meta.get('title'), mod['title']))
        if meta.get('subtopics') != mod['subtopics']:
            errors.append('%s: front matter subtopics differ from curriculum.md' % where)
        overrides = meta.get('heading_overrides') or {}
        expected = [overrides.get(s, s) for s in mod['subtopics']]
        topic_sections = [s for s in sections if norm(s['heading']) not in NON_TOPIC_H2]
        got = [s['heading'] for s in topic_sections]
        if [norm(x) for x in got] != [norm(x) for x in expected]:
            for e, g in zip(expected, got):
                if norm(e) != norm(g):
                    errors.append('%s: expected H2 %r, found %r' % (where, e, g))
                    break
            else:
                errors.append('%s: %d H2 sections for %d sub-topics' % (where, len(got), len(expected)))
        lab_ids = [l['id'] for l in meta.get('labs', [])]
        if [l[0] for l in labs] != lab_ids:
            errors.append('%s: lab headings %s != front matter labs %s' % (where, [l[0] for l in labs], lab_ids))
        seen = set()
        for l in meta.get('labs', []):
            for d in l.get('depends_on', []):
                if d in seen or d in earlier_labs:
                    continue
                if d in lab_ids:
                    errors.append('%s: %s depends on later lab %s' % (where, l['id'], d))
                else:
                    errors.append('%s: %s depends on unknown lab %s' % (where, l['id'], d))
            seen.add(l['id'])
        rows.append('Article: `articles/%s` - status: %s - sources last verified: %s\n'
                    % (p.name, meta.get('status'), meta.get('last_verified') or 'not yet'))
        rows.append('| # | Curriculum sub-topic | Article section | Diagrams | Code files | Inline blocks |')
        rows.append('|---|---|---|---|---|---|')
        by_norm = {norm(s['heading']): s for s in topic_sections}
        for i, (sub, exp) in enumerate(zip(mod['subtopics'], expected), 1):
            s = by_norm.get(norm(exp))
            if s:
                rows.append('| %d | %s | %s | %d | %d | %d |' % (i, sub, s['heading'], s['diagrams'], s['files'], s['inline']))
            else:
                rows.append('| %d | %s | MISSING | 0 | 0 | 0 |' % (i, sub))
        rows.append('')
        rows.append('Labs: %s\n' % ', '.join('%s (%s)' % (l['id'], l['title']) for l in meta.get('labs', [])))

    unknown = [n for n in articles if n > len(mods) or n < 1]
    for n in unknown:
        errors.append('article module %d has no curriculum module' % n)

    matrix = re.sub(r'\n{3,}', '\n\n', '# Coverage Matrix\n\nGenerated by `tools/check_coverage.py --write`. Do not edit by hand.\n\n' + '\n'.join(rows).rstrip() + '\n')
    if write:
        (ROOT / 'coverage-matrix.md').write_text(matrix)
    if errors:
        print('\n'.join(errors), file=sys.stderr)
        return 1
    print('coverage ok: %d of %d modules built' % (len(articles), len(mods)))
    return 0


if __name__ == '__main__':
    sys.exit(main('--write' in sys.argv))
