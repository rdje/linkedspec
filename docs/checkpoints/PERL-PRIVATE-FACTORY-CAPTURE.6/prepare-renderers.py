"""Derive distinct current Knowledge/book producers from retained accepted templates."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '64b66167c2277533c2393899e3754e14a74f0b31'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
sha = lambda value: hashlib.sha256(value).hexdigest()
target = ROOT / (PREFIX + 'derived-instruments.json')
assert not target.exists()
templates, current = {}, {}
for name in ('knowledge.py', 'book.py'):
    value = subprocess.check_output(['git', 'show', BASE + ':' + OLD + name], cwd=ROOT)
    assert (ROOT / (OLD + name)).read_bytes() == value
    templates[name] = value
    current[name] = value.replace(OLD.encode(), PREFIX.encode())
knowledge = current['knowledge.py']
knowledge = knowledge.replace(b"BASE='858eba97c89239d187765c4af9ad18057d28a1b0'", ('BASE=' + repr(BASE)).encode())
knowledge = knowledge.replace(b"'knowledge-preparation-final.json'", b"'documentation-preparation.json'")
knowledge = knowledge.replace(b'8388024', b'8384111').replace(b'10442', b'10448')
knowledge = knowledge.replace(b"sorted(prep['current'])", b"sorted(prep['changed_cards'])")
start = knowledge.index(b'extra += [PREFIX+n for n in (')
end = knowledge.index(b'\ncurrent={}', start)
extra = b'''extra += [PREFIX+n for n in ('knowledge.py','prepare-docs.py','documentation-preflight.json',
    'documentation-preparation.json','polish-workflow.py','workflow-polish.json',
    'prepare-renderers.py','derived-instruments.json','runtime.json','runtime-review-final.json')]
'''
knowledge = knowledge[:start] + extra.rstrip(b'\n') + knowledge[end:]
knowledge = knowledge.replace(b'changed_cards=changed,knowledge_bytes=total,',
                              b"changed_cards=changed,changed_bodies=prep['changed_bodies'],knowledge_bytes=total,")
start = knowledge.index(b"    scope='All1487")
end = knowledge.index(b')\nwith target.open', start)
scope = b"    scope='All1487 original/current Markdown bytes are retained; original archive modes and current actual filesystem modes stay separate. Fifteen current routes and two bodies preserve every whole original; thirteen bodies stay exact. Pure prewrite budget proof gives8384111 under unchanged8MiB. New pipeline/diagnostic conclusions use existing card IDs; no card file, decision or budget is added.'"
knowledge = knowledge[:start] + scope + knowledge[end:]
knowledge = knowledge.replace(b'15 routes/one body', b'15 routes/two bodies')
current['knowledge.py'] = knowledge
book = current['book.py']
book = book.replace(b"MARKER = 'Historical claim populations'", b"MARKER = 'Pipeline scope proof'")
book = book.replace(b"TARGET_MARKER = b'ControlFlow mixed-provider defaults'",
                    b"TARGET_MARKER = b'Invocation scopes and canonical apply'")
book = book.replace(b'modes[p] = int(mode, 8) & 0o777', b'modes[p] = (ROOT / p).stat().st_mode & 0o7777')
book = book.replace(b'.stat().st_mode & 0o777\n', b'.stat().st_mode & 0o7777\n')
book = book.replace(b'current workflow overlay and unchanged runtime teaching',
                    b'current pipeline workflow and native invocation-scope teaching overlays')
current['book.py'] = book
for name, value in current.items():
    compile(value, str(ROOT / (PREFIX + name)), 'exec')
    assert not (ROOT / (PREFIX + name)).exists()
record = dict(result='distinct derived producers; accepted originals unchanged', base=BASE,
              producer_sha256=sha(Path(__file__).read_bytes()),
              templates={name: dict(path=OLD + name, sha256=sha(value),
                                    bytes_base64=base64.b64encode(value).decode())
                         for name, value in templates.items()},
              current={name: sha(value) for name, value in current.items()},
              scope='Only declared current paths/metrics/overlay markers and actual-mode retention change. '
                    'Original .7 producers and their observations remain immutable; these new files '
                    'are the actual instruments for the current complete Knowledge/book commands.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
for name, value in current.items():
    with (ROOT / (PREFIX + name)).open('xb') as output:
        output.write(value)
print('Current complete Knowledge/book producers derived; accepted templates retained unchanged')
