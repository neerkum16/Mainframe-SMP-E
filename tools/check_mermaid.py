#!/usr/bin/env python3
"""Render every Mermaid block in the repository's Markdown files with mmdc.

Requires @mermaid-js/mermaid-cli (mmdc) on PATH.
Exit code 1 if any block fails to render.
"""
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONFIG = ROOT / 'tools' / 'puppeteer-config.json'
FENCE = re.compile(r'^```mermaid\n(.*?)^```', re.S | re.M)


def markdown_files():
    files = sorted((ROOT / 'articles').glob('*.md'))
    files += [ROOT / n for n in ('WORKFLOW.md', 'README.md', 'CONTRIBUTING.md')]
    return [f for f in files if f.is_file()]


def main():
    mmdc = shutil.which('mmdc')
    if not mmdc:
        print('mmdc not found; install @mermaid-js/mermaid-cli', file=sys.stderr)
        return 2
    failures = 0
    total = 0
    with tempfile.TemporaryDirectory() as tmp:
        for md in markdown_files():
            for i, block in enumerate(FENCE.findall(md.read_text()), 1):
                total += 1
                src = Path(tmp) / ('%s-%d.mmd' % (md.stem, i))
                src.write_text(block)
                res = subprocess.run(
                    [mmdc, '-q', '-p', str(CONFIG), '-i', str(src), '-o', str(src.with_suffix('.svg'))],
                    capture_output=True, text=True)
                if res.returncode != 0:
                    failures += 1
                    print('FAIL %s block %d\n%s' % (md.name, i, res.stderr.strip()[:600]), file=sys.stderr)
    print('mermaid: %d blocks, %d failed' % (total, failures))
    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())
