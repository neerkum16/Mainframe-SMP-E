#!/usr/bin/env python3
"""Expand include markers in articles/*.md into dist/*.md.

Include marker (on its own line):   <!-- include: labs/m01/jcl/FILE.jcl -->
Sources marker (on its own line):   <!-- sources -->

Each include becomes a caption line plus a fenced code block. The caption
shows the repository path, the z/OS member name and the verification status
recorded in labs/manifest.json.
"""
import json
import re
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
LANG = {'.jcl': 'jcl', '.mcs': 'text', '.smpcntl': 'text', '.rexx': 'rexx'}
INCLUDE = re.compile(r'^<!-- include: (\S+) -->\s*$')
FRONT = re.compile(r'\A---\n(.*?)\n---\n', re.S)


def load_manifest():
    data = json.loads((ROOT / 'labs' / 'manifest.json').read_text())
    return {e['path']: e for e in data}


def split_front_matter(text):
    m = FRONT.match(text)
    if not m:
        raise ValueError('missing front matter')
    return yaml.safe_load(m.group(1)), text[m.end():]


def status_text(entry):
    if entry.get('verified'):
        return 'verified: yes (%s, %s, %s)' % (
            entry.get('zos_release') or 'release not recorded',
            entry.get('verified_on') or 'date not recorded',
            entry.get('verified_by') or 'who not recorded')
    return 'verified: no'


def render_include(rel, manifest, errors, where):
    path = (ROOT / rel).resolve()
    if ROOT not in path.parents:
        errors.append('%s: include outside repository: %s' % (where, rel))
        return []
    if not path.is_file():
        errors.append('%s: include not found: %s' % (where, rel))
        return []
    entry = manifest.get(rel)
    if entry is None:
        errors.append('%s: include not in labs/manifest.json: %s' % (where, rel))
        return []
    body = path.read_text().rstrip('\n')
    caption = '`%s` - member `%s` - %s' % (rel, entry['member'], status_text(entry))
    return [caption, '', '```' + LANG[path.suffix], body, '```']


def render_sources(meta):
    out = ['## Sources', '']
    for s in meta.get('sources', []):
        out.append('- [%s](%s) - %s' % (s['title'], s['url'], s['release']))
    return out


def build_article(src, manifest, errors):
    meta, body = split_front_matter(src.read_text())
    out = []
    in_fence = False
    for n, line in enumerate(body.split('\n'), 1):
        if line.startswith('```'):
            in_fence = not in_fence
        m = INCLUDE.match(line) if not in_fence else None
        if m:
            out.extend(render_include(m.group(1), manifest, errors, '%s:%d' % (src.name, n)))
        elif line.strip() == '<!-- sources -->' and not in_fence:
            out.extend(render_sources(meta))
        else:
            out.append(line)
    return '\n'.join(out)


def main():
    manifest = load_manifest()
    errors = []
    dist = ROOT / 'dist'
    dist.mkdir(exist_ok=True)
    for old in dist.glob('*.md'):
        old.unlink()
    articles = sorted((ROOT / 'articles').glob('*.md'))
    for src in articles:
        text = build_article(src, manifest, errors)
        (dist / src.name).write_text(text)
    if errors:
        print('\n'.join(errors), file=sys.stderr)
        return 1
    print('built %d article(s) into dist/' % len(articles))
    return 0


if __name__ == '__main__':
    sys.exit(main())
