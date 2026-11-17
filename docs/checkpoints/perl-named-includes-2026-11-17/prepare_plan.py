"""Resolve the fourteen retained PPI do-site forms without loading their targets."""
import gzip
import hashlib
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PRIOR = Path('docs/checkpoints/perl-loader-token-census-2026-11-17')
assert not (BASE / 'plan.json').exists(), 'one-shot named-site plan'
old_plan = json.loads((PRIOR / 'plan.json').read_bytes())
result = json.loads(gzip.decompress((PRIOR / 'commands/consumers-stdout.gz').read_bytes()))
request = json.loads(gzip.decompress((PRIOR / 'commands/consumers-stdin.gz').read_bytes()))
sources = {row['path']: row['source'] for row in request['documents']}
entries = []
for document in result['documents']:
    assert hashlib.sha256(sources[document['path']].encode()).hexdigest() == document['source_sha256']
    for site in document['sites']:
        if site.get('word') != 'do' or site['context_hint'] == 'inline do block, not a file-include expression':
            continue
        expression = site['statement_content']
        direct = re.search(r"\bdo\s+'(\./t/[^'\n]+)'", expression)
        callable_path = re.search(r"\bdo File::Spec->catfile\(\$repo_root, 't', '([^'\n]+)'\)", expression)
        ast_path = re.search(r"\bdo File::Spec->catfile\(File::Basename::dirname\(__FILE__\), '([^'\n]+)'\)", expression)
        assert sum(match is not None for match in (direct, callable_path, ast_path)) == 1, 'closed source-expression vocabulary'
        if direct:
            target = direct[1].removeprefix('./')
            route = 'literal root-cwd-relative operand; source qualifier, not actual resolved-origin proof'
        elif callable_path:
            assert 'my $repo_root = dirname(dirname(File::Spec->rel2abs(__FILE__)));' in sources[document['path']]
            target = 't/' + callable_path[1]
            route = 'source-derived parent repository root plus literal t/name'
        else:
            assert document['path'] == 't/actionir_ast_parser.t'
            target = str(Path(document['path']).parent / ast_path[1])
            route = 'source parent directory via __FILE__ plus literal name'
        entries.append(dict(parent=document['path'], target=target, ordinal=site['ordinal'], location=site['location'],
            expression=expression, source_sha256=document['source_sha256'], route=route))
assert len(entries) == 14 and len({row['target'] for row in entries}) == 14
assert len({row['parent'] for row in entries}) == 3
plan = dict(owner='TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.3.1.1.0',
    activation='5909a0253a4ead9a1a430ba64d0de4836709641f', cwd='.', ppi_version=old_plan['ppi_version'],
    prior_census=str(PRIOR), entries=entries,
    context_targets=['t/actionir_legacy_hash_kind_cold_probe.pl'],
    old_named_ledger='docs/checkpoints/perl-consumer-roles-2026-11-16/named-includes.json',
    old_source_identities='docs/checkpoints/perl-consumer-roles-2026-11-16/identities.json',
    old_roles='docs/checkpoints/perl-consumer-roles-2026-11-16/roles.json',
    lexer=str(PRIOR / 'lexer.pl'),
    words=['use', 'no', 'require', 'do', 'package', 'sub', 'caller', 'done_testing', 'observations', 'cases',
        'open', 'print', 'system', 'exec', 'eval', 'cold'],
    limits='Fourteen source-derived logical include targets and one nested child context. No actual file resolution, imports, test execution, child launch, complete transitive graph, native/source-origin/per-read/physical closure or canonical admission.')
(BASE / 'plan.json').write_text(json.dumps(plan, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(result='PASS', entries=len(entries), parents=sorted({row['parent'] for row in entries}),
    targets=[row['target'] for row in entries], limits=plan['limits']), indent=2, sort_keys=True))
