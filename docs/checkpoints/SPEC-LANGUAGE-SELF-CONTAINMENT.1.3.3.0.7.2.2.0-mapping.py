"""Capture Toolbox observations and falsify two proposed raw-key mappers.

The candidate algorithms run on measured event arrays; production is unchanged.
Fixture positions/real occurrence order are independent, declared inputs.
"""
from pathlib import Path
import importlib.util
import json
import os
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0-'
spec = importlib.util.spec_from_file_location('capture', ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py')
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)
cases = json.loads((ROOT / (PREFIX + 'mapping-cases.json')).read_bytes())
command = ['perl', '-Iperl', PREFIX + 'mapping-probe.pl']
result = subprocess.run(command, cwd=ROOT, capture_output=True,
                        env=dict(os.environ, PERL5LIB='', PERL_HASH_SEED='0', PERL_PERTURB_KEYS='2'))
report = {'command': command, 'exit': result.returncode,
          'stdout': capture.envelope(result.stdout), 'stderr': capture.envelope(result.stderr)}
assert result.returncode == 0 and not result.stderr
observed = json.loads(result.stdout)
simulations = []
for case, row in zip(cases, observed['cases'], strict=True):
    assert case['id'] == row['id'] and case['action'] == row['action']
    events = [event for event in row['diagnostics']['helper_action_ir_events']
              if event['contract_id'] == case['contract']]
    quoted = (case['quoted_start'], case['quoted_start'] + len(case['quoted_raw']))
    cursors = {}
    kept = []
    decisions = []
    for event in events:
        raw = event['raw']
        start = case['action'].find(raw, cursors.get(raw, 0))
        if case['candidate'] == 'skip_quoted_per_raw':
            while start != -1 and quoted[0] <= start < quoted[1]:
                start = case['action'].find(raw, start + len(raw))
        cursors[raw] = start + len(raw) if start != -1 else len(case['action'])
        accepted = start != -1 and not quoted[0] <= start < quoted[1]
        decisions.append({'raw': raw, 'mapped_start': start, 'kept': accepted})
        if accepted:
            kept.append({'raw': raw, 'start': start})
    expected = [{'raw': raw, 'start': start} for raw, start in
                zip(case['real_raws'], case['real_starts'], strict=True)]
    assert kept != expected, 'candidate unexpectedly meets independent occurrence oracle'
    simulations.append({'id': case['id'], 'candidate': case['candidate'],
                        'decisions': decisions, 'actual_kept': kept, 'expected': expected,
                        'oracle_matches': False})
report['candidate_simulations'] = simulations
(ROOT / (PREFIX + 'mapping.json')).write_text(json.dumps(report, indent=2) + '\n')
print('PASS two actually executed candidate mappers fail independent source-occurrence oracles')
