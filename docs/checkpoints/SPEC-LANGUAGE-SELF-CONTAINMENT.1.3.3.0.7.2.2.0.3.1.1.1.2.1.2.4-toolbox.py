"""Capture current public Toolbox lowering against the retained pre-change oracle."""
import base64
import hashlib
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.4-'
CASES = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0-cases.json'
CODE = '''use LinkedSpec (); use JSON::PP ();
my $j = JSON::PP->new->utf8->canonical;
open my $f, '<:raw', $ARGV[0] or die $!;
my $cases = $j->decode(do { local $/; <$f> }); close $f or die $!;
print $j->encode([map { +{id => $_->{id}, lowered =>
LinkedSpec::call_spec_handler_subst('Top', 'return('.$_->{source}.')')} }
grep { $_->{id} ne 'empty-slots' } @$cases]), "\\n";
'''

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

paths = subprocess.check_output(['git', 'ls-files', '-z', '--', 'perl', 'specs'], cwd=ROOT).decode().split('\0')
inputs = {p: digest((ROOT / p).read_bytes()) for p in paths + [CASES, PREFIX + 'toolbox.py'] if p and (ROOT / p).is_file()}
command = ['perl', '-Iperl', '-e', CODE, CASES]
result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, PERL5LIB='', PERL5OPT=''),
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
row = {'command': command, 'returncode': result.returncode, 'inputs': inputs,
       'stdout_base64': base64.b64encode(result.stdout).decode(),
       'stderr_base64': base64.b64encode(result.stderr).decode(),
       'unchanged': all(digest((ROOT / p).read_bytes()) == h for p, h in inputs.items())}
(ROOT / (PREFIX + 'toolbox.json')).write_text(json.dumps(row, indent=2) + '\n')
assert row['unchanged'] and result.returncode == 0
print('Actual call_spec_handler_subst capture exit', result.returncode)
