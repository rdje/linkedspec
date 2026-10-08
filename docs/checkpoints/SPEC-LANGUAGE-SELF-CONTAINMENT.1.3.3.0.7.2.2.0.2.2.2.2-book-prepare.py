"""Prepare a new actual renderer for committed membership acceptance teaching."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('book-prepare.py')
REPAIR = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1-'


def main():
    target = Path(PREFIX + 'book.py'); assert not target.exists()
    text = (ROOT / (REPAIR + 'book.py')).read_text()
    text = text.replace('with canonical acceptance open', 'with independently committed acceptance')
    old = "'Compiler membership acceptance remains open'"
    new = "'Compiler membership acceptance independently recurs',\n                   'Exact staged canonical proof is also required before closure'"
    assert text.count(old) == 1; text = text.replace(old, new, 1)
    target.write_text(text)
    print('Prepared new58-input/five-example actual publication producer')


if __name__ == '__main__':
    main()
