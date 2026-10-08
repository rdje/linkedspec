"""Create a new actual renderer for the bounded replacement diagnosis."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('book-prepare.py')
PRIOR = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.2-book.py'
EXAMPLES = [
    'Top:: I { quoted=\'out=matches("x", /x/)\'; out=matches("x", /x/); return([quoted,out]) }\n'
    '# current Perl: handler compilation fails after the quoted payload is rewritten',
    'Top:: I { out=matches("x", /x/); quoted=\'out=matches("x", /x/)\'; return([quoted,out]) }\n'
    '# result: ["out=matches(\\"x\\", /x/)", 1]',
]


def main():
    target = Path(PREFIX + 'book.py'); assert not target.exists()
    text = (ROOT / PRIOR).read_text()
    anchor = ']\n\n\ndef envelope'; assert text.count(anchor) == 1
    text = text.replace(anchor, ''.join('    ' + repr(example) + ',\n' for example in EXAMPLES) + anchor)
    anchor = "                   'statement-splitter signature repair still holds')"
    assert text.count(anchor) == 1
    text = text.replace(anchor, "                   'statement-splitter signature repair still holds',\n"
        "                   'Selection and replacement have separate source obligations',\n"
        "                   'selected-occurrence repair remains open')")
    anchor = "        ('failed render', lambda r: r.update(exit=1)),"
    assert text.count(anchor) == 1
    text = text.replace(anchor, anchor + '\n'
        "        ('hidden replacement boundary', lambda r: r.update(html=envelope(decode(r['html']).replace(\n"
        "            b'Selection and replacement have separate source obligations', b'boundary removed')))),\n"
        "        ('lost failing-order example', lambda r: r.update(html=envelope(decode(r['html']).replace(\n"
        "            b'# current Perl: handler compilation fails', b'# example removed')))),")
    target.write_text(text)
    print('Prepared seven-example diagnosis renderer; original producer unchanged')


if __name__ == '__main__':
    main()
