"""Inspect decoded actual HTML, retaining the original entity-assumption failure."""
import gzip
import html
import json
import re
import shutil
import os
from pathlib import Path
import book
import common as c


def verify(row, changed=False):
    assert row['returncode'] == 0 and row['source_bytes_modes_unchanged']
    assert b'ERROR' not in c.decode(row['stderr_base64'])
    pages = {path: c.decode(item['base64']) for path, item in row['pages'].items()}
    for path, item in row['pages'].items():
        assert c.sha(pages[path]) == item['sha256']
    main = pages[book.PAGE].split(b'<main>', 1)[1].rsplit(b'</main>', 1)[0]
    decoded = html.unescape(main.decode())
    anchor = 'id="migrating-the-retired-tagged-returns"'
    if changed:
        assert anchor not in decoded and 'id="changed-migration-heading"' in decoded
    else:
        assert anchor in decoded and 'flat_array(entry_groups())' in decoded
        assert '["?Top:","ab","c",["seed"]]' in decoded
        assert 'not promise reference identity' in decoded
        for path in ('appendix/formal-grammar.html', 'appendix/helper-contract-catalog.html'):
            assert b'../dsl/values-containers-and-flow-helpers.html#migrating-the-retired-tagged-returns' in pages[path]
    return decoded


def review(fresh=True):
    inputs = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'book-final-inputs.json.gz')).read_bytes()))
    prior = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'book-final-run.json.gz')).read_bytes()))
    assert c.unchanged(inputs['inputs']) and inputs['producer'] == c.read(c.PREFIX + 'book-final.py')
    actual, count = book.population()
    assert actual == inputs['inputs'] and count == inputs['book_sources'] == 57
    assert len(actual)-count == prior['recursive_include_sources'] == 32
    assert verify(prior['healthy']) != verify(prior['changed_heading'], True)
    # Original reader's actual false negative remains independently reproducible.
    try:
        book.verify(json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'book-run.json.gz')).read_bytes()))['healthy'])
    except AssertionError:
        pass
    else:
        raise AssertionError('original entity-assumption failure unexpectedly disappeared')
    chapter = c.decode(actual[book.CHAPTER]['base64']).decode()
    example = re.search(r'```text\n(Root::\n.*?\n I \{ set\(Top, \["seed"\]\).*?)\n```', chapter, re.S)
    assert example, 'actual public complete worked example'
    native = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'flat-ma-inputs.json.gz')).read_bytes()))
    assert example[1] + '\n' == native['cases'][0]['spec'], 'rendered public example equals actually executed source'
    tool = shutil.which(os.environ.get('LINKEDSPEC_MDBOOK_CMD', 'mdbook'))
    assert tool and c.sha(Path(tool).read_bytes()) == inputs['tool']['sha256']
    if fresh:
        healthy, changed = book.render(actual), book.render(actual, True)
        assert verify(healthy) != verify(changed, True)
    assert c.unchanged(actual)
    return dict(result='PASS', inputs=len(actual), book_sources=count,
        scope='Complete current supplied book/includes render; three affected page payload/links, '
              'actual code example/native equality and changed-heading RED. Original entity reader failure '
              'and both complete build channels remain retained. No complete type-reference inventory admission.')


if __name__ == '__main__':
    print(json.dumps(review(), sort_keys=True))
