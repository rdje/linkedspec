"""Inventory repository-owned scanner source; counts describe textual sites only."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0-'
core_path = 'perl/LinkedSpec/ActionIR/ScannerCore.pm'
core = (ROOT / core_path).read_text()
family_body = core.split('sub _scanner_rule_family_packages {', 1)[1].split('\n}', 1)[0]
packages = re.findall(r"'(LinkedSpec::ActionIR::[^']+)'", family_body)
assert len(packages) == 7 and len(set(packages)) == 7
families = []
for package in packages:
    path = 'perl/' + package.replace('::', '/') + '.pm'
    data = (ROOT / path).read_bytes()
    source = data.decode()
    starts = list(re.finditer(r'^sub (\w+)\s*\{', source, re.M))
    functions = []
    for index, match in enumerate(starts):
        end = starts[index + 1].start() if index + 1 < len(starts) else len(source)
        body = source[match.start():end]
        constructors = len(re.findall(r'push\s+@events\s*,\s*\{', body))
        nested = re.findall(r'push\s+@events\s*,\s*@\{(_\w+)\(([^\n]+)\)\}', body)
        if constructors or nested:
            functions.append({'name': match[1], 'line': source[:match.start()].count('\n') + 1,
                              'literal_event_constructors': constructors,
                              'nested_or_composed_event_calls': [{'callee': a, 'arguments': b} for a, b in nested],
                              'statement_split_calls': body.count('_split_action_ir_statements('),
                              'regex_global_loops': len(re.findall(r'while\s*\([^\n]*=~[^\n]*/g', body))})
    families.append({'package': package, 'path': path, 'sha256': hashlib.sha256(data).hexdigest(),
                     'event_producer_functions': functions})
report = {'scope': 'Seven exact current dispatcher-family source files. Textual event construction and nested/composed call sites, not a runtime reachability/contract census.',
          'core_path': core_path, 'core_sha256': hashlib.sha256((ROOT / core_path).read_bytes()).hexdigest(),
          'families': families}
(ROOT / (PREFIX + 'inventory.json')).write_text(json.dumps(report, indent=2) + '\n')
for family in families:
    functions = family['event_producer_functions']
    print(f"{family['package']}: {len(functions)} producer functions, "
          f"{sum(row['literal_event_constructors'] for row in functions)} literal construction sites, "
          f"{sum(len(row['nested_or_composed_event_calls']) for row in functions)} nested/composed calls")
