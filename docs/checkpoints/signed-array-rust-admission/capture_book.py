"""Complete supplied-book render with an actual changed admission statement."""
import copy
import html
import sys
import admission_common as a

PATH = 'docs/linkedspec-book/src/development/local-ci-and-regression.md'
MARKER = 'Rust signed-selector admission permits only the exact reviewed before/after runtime source pair.'


def validate(run):
    assert run['returncode'] == 0, 'book build'
    assert MARKER in html.unescape(a.decode(run['page_base64']).decode()), 'exact runtime admission boundary'


def main():
    sys.path.insert(0, str(a.ROOT/'docs/checkpoints/signed-array-rust'))
    import book
    book.HTML = 'development/local-ci-and-regression.html'
    supplied = book.inputs()
    own = {path: a.read(path) for path in [a.PREFIX+'capture_book.py', a.PREFIX+'admission_common.py',
        'docs/checkpoints/signed-array-rust/book.py', 'docs/checkpoints/signed-array-rust/common.py']}
    a.save('book-inputs.json.gz', dict(inputs=supplied, producer_inputs=own,
        scope='Whole book configuration/sources/recursive includes. Reuse only sealed pure input/render functions with the affected development page selected. Installed mdBook/OS are read-only prerequisites.'))
    healthy = book.render(supplied)
    validate(healthy)
    variant = copy.deepcopy(supplied)
    raw = a.decode(variant[PATH]['base64'])
    assert raw.count(MARKER.encode()) == 1
    raw = raw.replace(MARKER.encode(), b'Rust signed-selector admission permits any runtime source image.', 1)
    variant[PATH].update(base64=a.encode(raw), sha256=a.sha(raw))
    fault = book.render(variant)
    assert fault['returncode'] == 0
    try:
        validate(fault)
    except AssertionError as error:
        assert str(error) == 'exact runtime admission boundary'
        rejected = True
    else:
        raise AssertionError('changed rendered source was admitted')
    stable = all(a.read(path) == packet for path, packet in supplied.items())
    a.save('book-runs.json.gz', dict(healthy=healthy, fault=fault,
        fault_input={PATH: variant[PATH]}, fault_rejected=rejected, inputs_unchanged=stable))
    assert stable
    print('Supplied95-input book and actual changed runtime-admission statement denial PASS.')


if __name__ == '__main__':
    main()
