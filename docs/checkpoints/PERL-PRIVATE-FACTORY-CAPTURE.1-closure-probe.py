"""Diagnose the actual draft factory's callback identities before correcting it."""
import base64
import hashlib
import json
import os
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.1-'
FIXTURE = PREFIX + 'draft1-fixture.t'
raw = (ROOT / FIXTURE).read_bytes()
factory = re.search(rb'^sub factory \{.*\}$', raw, re.MULTILINE).group()
program = b'use Scalar::Util qw(refaddr);\n' + factory + b'''
my $left = factory(); my $right = factory();
print "same_actual_callback=", (refaddr($left) == refaddr($right) ? 1 : 0), "\n";
sub lexical_factory { my $identity = {}; return sub { ++$identity->{calls}; return 'same' } }
my $a = lexical_factory(); my $b = lexical_factory();
print "distinct_lexical_callbacks=", (refaddr($a) != refaddr($b) ? 1 : 0), "\n";
'''
target = ROOT / (PREFIX + 'closure-probe.json')
assert not target.exists(), 'one-shot diagnosis already published'
command = ['perl', '-e', program.decode()]
result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, PERL5LIB='', PERL5OPT=''),
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
target.write_text(json.dumps({
    'producer_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    'fixture': FIXTURE, 'fixture_sha256': hashlib.sha256(raw).hexdigest(),
    'command': command, 'returncode': result.returncode,
    'stdout_base64': base64.b64encode(result.stdout).decode(),
    'stderr_base64': base64.b64encode(result.stderr).decode(),
    'scope': 'The actual draft factory body is extracted unchanged. Two calls return one actual CODE reference; lexical state produces distinct closures. This diagnoses an invalid fixture assumption, not a production registry failure.'
}, indent=2) + '\n')
assert result.returncode == 0 and result.stdout == b'same_actual_callback=1\ndistinct_lexical_callbacks=1\n'
assert not result.stderr
print('Draft callback identity diagnosis PASS: native shared reference; lexical closures distinct')
