"""Recover a bounded Perl role ledger without running Perl or capture writers."""
import argparse
from collections import Counter
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import shlex
import stat
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
PRIOR = 'docs/checkpoints/canonical-discovery-inventory-2026-11-16/'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.1'
MAINTENANCE = {
    't/document_history_catalog.t': 'bounded document-history catalog',
    't/knowledge_map_header_lists.t': 'Knowledge Map front-matter list projection',
}
PIPELINE = 't/array_pipeline_value_contract.t'
DEFAULT = 't/default_literal_operand_contract.t'
CALLABLE = 't/callable_codeblock_literal_contract.t'


def require(value, reason):
    if not value:
        raise ValueError(reason)


def recover():
    inputs = {}
    with tarfile.open(BASE / 'inputs.tar.gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            require(not path.is_absolute() and str(path) == member.name
                    and '..' not in path.parts and member.isfile()
                    and member.name not in inputs, 'archive namespace')
            inputs[member.name] = (archive.extractfile(member).read(), member.mode)
    identities = json.loads((BASE / 'identities.json').read_bytes())
    require(inputs.keys() == identities.keys(), 'archive population')
    for name, (body, mode) in inputs.items():
        require(hashlib.sha256(body).hexdigest() == identities[name]['sha256'], 'input bytes')
        require(mode == identities[name]['mode'], 'input mode')
    listing = json.loads(gzip.decompress((BASE / 'git-tree.json.gz').read_bytes()))
    require(listing['exit'] == 0 and listing['stderr_hex'] == '' and listing['cwd'] == '.', 'git channels')
    require(listing['argv'][:5] == ['git', 'ls-tree', '-rz',
            '3f619e9c2aa74d0f3f8d9d64c2c90e82d11d81e0', '--'], 'activation')
    tree = {}
    for cell in bytes.fromhex(listing['stdout_hex']).split(b'\0'):
        if not cell:
            continue
        header, name = cell.split(b'\t')
        mode, kind, blob = header.decode().split()
        require(kind == 'blob', 'git kind')
        tree[name.decode()] = (mode, blob)
    require(set(tree) == set(listing['argv'][5:]), 'git population')
    for name, (mode, blob) in tree.items():
        body, permissions = inputs[name]
        require(hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest() == blob,
                'activation body')
        require(mode == ('100755' if permissions & 0o111 else '100644'), 'activation mode')
    return inputs


def selection(source):
    """Independent narrow shell-word interpretation, including the supplied array."""
    result, array, active = [], [], False
    for line in source.splitlines():
        if line == 'private_factory_suites=(':
            active = True
            continue
        if active:
            if line == ')':
                active = False
            else:
                array.extend(shlex.split(line, comments=True))
            continue
        # Only unindented, unconditional prove statements in the retained runner.
        if not line or line[0].isspace():
            continue
        words = shlex.split(line, comments=True)
        if 'prove' not in words:
            continue
        start = words.index('prove')
        require(all('=' in word for word in words[:start]), 'selector vocabulary')
        for word in words[start + 1:]:
            if word == '${private_factory_suites[@]}':
                require(array, 'private suite array')
                result.extend(array)
            elif word.endswith('.t'):
                result.append(word)
    require(not active, 'unterminated array')
    return result


def reconstruct(inputs):
    prior = json.loads(gzip.decompress(inputs[PRIOR + 'inventory.json.gz'][0]))
    candidates = [row for row in prior['rows'] if row['backend'] == 'perl'
                  and (row['required'] or row['review_candidate'])]
    source = inputs['tools/run_ci_local.sh'][0].decode()
    selected = selection(source)
    observed = [row['path'] for row in prior['perl_events'] if row['kind'] == 'selected_test']
    require(selected == observed, 'actual Bash selector disagrees')
    wire = gzip.decompress(inputs[PRIOR + 'perl-selector-stdout.gz'][0]).split(b'\0')
    require(wire.pop() == b'' and len(wire) % 2 == 0, 'actual selector wire')
    require([wire[i + 1].decode() for i in range(0, len(wire), 2)
             if wire[i] == b'selected_test'] == selected, 'actual selector channels')
    counts = Counter(selected)
    callable_source = inputs[CALLABLE][0].decode()
    includes = []
    for number, line in enumerate(callable_source.splitlines(), 1):
        match = re.fullmatch(r"    do File::Spec->catfile\(\$repo_root, 't', '([^']+\.t)'\) or die \$@ \|\| \$!;", line)
        if match:
            target = 't/' + match[1]
            require(target in inputs, 'missing named include input')
            require('done_testing() unless caller;' in inputs[target][0].decode(), 'included plan boundary')
            includes.append(dict(parent=CALLABLE, target=target, line=number, expression=line))
    require(len(includes) == callable_source.count('do File::Spec->catfile('), 'unclassified callable do')
    require(counts[CALLABLE] == 1, 'callable selected once')
    included = {row['target']: row for row in includes}
    require(PIPELINE in included and DEFAULT not in included, 'pipeline/default distinction')
    rows = []
    for candidate in candidates:
        name = candidate['path']
        body, _ = inputs[name]
        require(hashlib.sha256(body).hexdigest() == candidate['sha256'], 'prior consumer source')
        text = body.decode()
        lines = text.splitlines()
        imports = [dict(line=i, expression=line) for i, line in enumerate(lines, 1)
                   if line in ('use Test::More;', 'require Test::More;')]
        plans = [dict(line=i, expression=line) for i, line in enumerate(lines, 1)
                 if re.fullmatch(r'(?:Test::More::)?done_testing(?:\(\))?(?: unless caller)?;', line)]
        require(len(imports) == 1 and plans, 'test harness and completion source')
        if name in MAINTENANCE:
            role, rationale = 'maintenance-suite', MAINTENANCE[name]
        elif candidate['required']:
            role, rationale = 'feature-suite', 'parent feature obligation or changed maintained feature consumer'
        else:
            role, rationale = 'compatibility-suite', 'existing feature regression retained alongside the proposed population'
        if counts[name]:
            route = dict(kind='direct-unconditional-selection', occurrences=counts[name])
        elif name in included:
            route = dict(kind='named-include-from-selected-suite', edge=included[name])
        else:
            route = dict(kind='no-direct-or-named-callable-selection')
        rows.append(dict(path=name, role=role, rationale=rationale,
                         admission_owner=OWNER if role != 'maintenance-suite' else None,
                         prior_task_references=candidate['task_references'],
                         harness=imports[0], completion=plans, route=route))
    return rows, includes


def validate(inputs, ledger):
    expected, includes = reconstruct(inputs)
    require(ledger == expected, 'role ledger differs from source')
    return dict(result='PASS', candidates=len(ledger),
                roles=dict(sorted(Counter(row['role'] for row in ledger).items())),
                routes=dict(sorted(Counter(row['route']['kind'] for row in ledger).items())),
                named_callable_includes=len(includes),
                direct_repetitions={row['path']: row['route']['occurrences'] for row in ledger
                                    if row['route']['kind'] == 'direct-unconditional-selection'
                                    and row['route']['occurrences'] > 1},
                default_literal_registration_owner='TYPE-REFERENCE-BOOK.1.2.23.4.1.2',
                limits='Static named Perl candidate roles and direct/named callable selection only. No Perl test execution, complete dynamic include/input graph, native discovery, default resolution, canonical inclusion or full population claim. Complete native/source-origin/physical custody remains4.2/SESSION5.')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--current', action='store_true')
    args = parser.parse_args()
    inputs = recover()
    # Require the actual review producer to match its retained image.
    name = str(BASE.relative_to(ROOT) / 'review.py')
    require(Path(__file__).read_bytes() == inputs[name][0], 'review producer')
    ledger = json.loads((BASE / 'roles.json').read_bytes())
    result = validate(inputs, ledger)
    mutations = {}
    for kind in ('missing', 'duplicate', 'maintenance-promoted', 'include-promoted-to-missing',
                 'unselected-default-promoted', 'duplicate-selection-hidden', 'owner-removed'):
        changed = copy.deepcopy(ledger)
        if kind == 'missing':
            changed.pop()
        elif kind == 'duplicate':
            changed.append(copy.deepcopy(changed[0]))
        else:
            target = {'maintenance-promoted': 't/document_history_catalog.t',
                      'include-promoted-to-missing': PIPELINE,
                      'unselected-default-promoted': DEFAULT,
                      'duplicate-selection-hidden': 't/actionir_receiver_scalar_copy.t',
                      'owner-removed': DEFAULT}[kind]
            row, = [row for row in changed if row['path'] == target]
            if kind == 'maintenance-promoted':
                row['role'] = 'feature-suite'
            elif kind == 'owner-removed':
                row['admission_owner'] = None
            elif kind == 'duplicate-selection-hidden':
                row['route']['occurrences'] = 1
            else:
                row['route'] = dict(kind='no-direct-or-named-callable-selection') if kind.startswith('include') else dict(kind='direct-unconditional-selection', occurrences=1)
        try:
            validate(inputs, changed)
        except ValueError as error:
            mutations[kind] = dict(result='RED', reason=str(error))
        else:
            raise ValueError('control accepted: ' + kind)
    result['controls'] = mutations
    if args.current:
        for name, (body, mode) in inputs.items():
            path = ROOT / name
            require(path.is_file() and not path.is_symlink() and path.read_bytes() == body
                    and stat.S_IMODE(path.stat().st_mode) == mode, 'current identity: ' + name)
        result['current_inputs'] = len(inputs)
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
