"""Match captured owned Perl modules by their repository-relative module identity."""
from pathlib import PurePosixPath


def verify(loaded, supplied):
    roots = set()
    for module, actual in loaded.items():
        key = PurePosixPath(module)
        assert not key.is_absolute() and '..' not in key.parts, ('unsafe captured module key', module)
        relative = module if module.startswith('perl/') else 'perl/' + module
        if relative in supplied:
            if actual == relative:
                continue
            suffix = '/' + relative
            assert actual.startswith('/') and actual.endswith(suffix), ('owned module path/key mismatch', module, actual)
            roots.add(actual[:-len(suffix)])
        else:
            assert actual.startswith('/System/Library/Perl/'), ('unsupplied noncore module', module, actual)
    assert len(roots) <= 1, 'one original repository root for captured owned absolute module paths'
    return True
