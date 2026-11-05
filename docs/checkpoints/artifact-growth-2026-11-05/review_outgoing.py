"""Read-only fixed outgoing-range review; --capture is a one-shot metadata writer.

No pack generation, fetch, push, remote-size inference or dependency traversal.
The director's approximate pack estimate is attribution, not a new measurement.
"""
import argparse
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
BASE = '4683555ec51f04b8977812ce4e984c5cc6e6f42c'
HEAD = 'eda3c81fe6ca9264f0ba96f3f90525d96d79626c'
ARTIFACT = 'docs/checkpoints/signed-array-contract-admission/import-epoch-before.json.gz'
OUTPUT = HERE / 'outgoing-scope.json'


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT, text=True).strip()


def observe():
    return {
        'base': BASE, 'head': HEAD,
        'count': int(git('rev-list', '--count', BASE + '..' + HEAD)),
        'left_right': git('rev-list', '--left-right', '--count', BASE + '...' + HEAD),
        'commits': git('log', '--format=%H', BASE + '..' + HEAD).splitlines(),
        'warned_blob_at_base': git('rev-parse', BASE + ':' + ARTIFACT),
        'warned_blob_at_head': git('rev-parse', HEAD + ':' + ARTIFACT),
    }


def validate(report, oracle):
    assert report['git'] == oracle, 'fixed Git range mismatch'
    assert oracle['count'] == len(set(oracle['commits']))
    assert oracle['left_right'].split() == ['0', str(oracle['count'])]
    assert oracle['warned_blob_at_base'] == oracle['warned_blob_at_head']
    assert report['warned_blob_new_to_range'] is False, 'already-published blob attribution'
    assert report['director_pack_estimate'] == {
        'text': '11.5MB', 'source': 'director correction in this session',
        'independent_pack_measurement': False,
    }, 'unmeasured estimate attribution'
    assert report['whole_local_store_is_outgoing_pack'] is False, 'whole-store/outgoing conflation'


def controls(report, oracle):
    rejected = []
    for name in ('wrong-ahead-count', 'published-blob-as-new', 'whole-store-as-outgoing'):
        changed = copy.deepcopy(report)
        if name == 'wrong-ahead-count': changed['git']['count'] += 1
        elif name == 'published-blob-as-new': changed['warned_blob_new_to_range'] = True
        else: changed['whole_local_store_is_outgoing_pack'] = True
        try:
            validate(changed, oracle)
        except AssertionError:
            rejected.append(name)
        else:
            raise AssertionError('ineffective control: ' + name)
    return rejected


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', action='store_true')
    args = parser.parse_args()
    oracle = observe()
    if args.capture:
        assert not OUTPUT.exists(), 'capture is one-shot'
        assert git('rev-parse', 'HEAD') == HEAD and git('rev-parse', 'origin/main') == BASE
        report = {
            'at_utc': datetime.now(timezone.utc).isoformat(), 'git': oracle,
            'warned_blob_new_to_range': False,
            'director_pack_estimate': {'text': '11.5MB',
                'source': 'director correction in this session',
                'independent_pack_measurement': False},
            'whole_local_store_is_outgoing_pack': False,
            'limits': 'Fixed locally recorded refs and one named blob, not fresh remote state, exact pack/wire bytes, server size or current future ahead count.'
        }
        report['rejected_controls'] = controls(report, oracle)
        OUTPUT.write_text(json.dumps(report, indent=2) + '\n')
    report = json.loads(OUTPUT.read_text())
    validate(report, oracle)
    assert controls(report, oracle) == report['rejected_controls']
    print(json.dumps({'result': 'PASS', 'fixed_range_commits': oracle['count'],
        'warned_blob_already_at_base': True,
        'director_pack_estimate': report['director_pack_estimate'],
        'rejected_controls': report['rejected_controls']}, sort_keys=True))


if __name__ == '__main__':
    main()
