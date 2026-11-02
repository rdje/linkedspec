"""One-shot custody for the nine reached factory consumers before repair."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
DESTINATION = HERE / 'factory-intake.json.gz'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def capture():
    assert not DESTINATION.exists(), 'preserve completed intake epochs'
    runner = (ROOT / 'tools/run_ci_local.sh').read_text()
    selected = runner[runner.index('private_factory_suites=('):runner.index('log "checking complete private factory fixture inputs and syntax"')]
    names = set(re.findall(r'^ (\S+\.(?:t|pl))$', selected, re.M))
    assert len(names) == 137
    names.update(subprocess.check_output(['git', 'ls-files', '--', 'perl', 't/lib'], cwd=ROOT).decode().splitlines())
    names.update([
        'tools/run_ci_local.sh', 'tools/project_data_run.sh', 'tools/project_data_env.sh',
        'tools/run_python_project_data.sh', str(Path(__file__).relative_to(ROOT)),
        'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5-before-stable-native.json',
        'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3-before-native.json',
        'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3-before-authority-native.json',
        'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-before-native.json',
        'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-native.json',
        'tests/numeric-codeblocks/legacy-consumers.json',
        'docs/knowledge/perl-receiver-copy-canonical-selection.md',
        'docs/knowledge/perl-factory-capture-framework.md',
        'docs/knowledge/perl-method-block-component-capture.md',
        'docs/knowledge/perl-method-ast-call-capture.md',
        'docs/knowledge/terse-type-method-surface-inventory.md',
        'docs/checkpoints/type-evaluated-values/README.md',
        'docs/linkedspec-book/src/development/local-ci-and-regression.md',
    ])
    inputs = {name: packet((ROOT / name).read_bytes()) for name in sorted(names)}
    source = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
    before = subprocess.check_output(['git', 'show', 'c053c9dcf24a78cc8b551187f47cdb7aefb03eb3:' + source], cwd=ROOT)
    saved = dict(owner='TYPE-REFERENCE-BOOK.1.2.20.1.18', inputs=inputs,
                 coordinate_authority=dict(revision='c053c9dcf24a78cc8b551187f47cdb7aefb03eb3', path=source, **packet(before)),
                 failure=packet((ROOT / '.linkedspec-data/normal-hook-restoration/canonical-ci.log').read_bytes()),
                 limits='Complete selected137-path source population, project Perl and test-library sources, five directly consumed historical native records and current local authority before any component18 fixture/probe/runtime repair. This is intake custody, not a passing repair or transitive dependency/feature admission.')
    DESTINATION.write_bytes(gzip.compress(json.dumps(saved, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
    print('factory intake retained:', len(inputs), 'inputs')


if __name__ == '__main__':
    capture()
