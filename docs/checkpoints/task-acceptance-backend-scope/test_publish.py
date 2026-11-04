"""Synthetic publication protocol controls; no network or other Git repository."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent


def scenario(kind):
    spec = importlib.util.spec_from_file_location('publication_fixture', HERE / 'publish.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    plan = json.loads((HERE / 'push-plan.json').read_bytes())
    head = 'f' * 40
    main_ref = 'refs/heads/main'
    temporary = 'refs/heads/codex/upload-backlog-' + head[:12]
    refs = {main_ref: plan['remote_base']}
    calls = []
    run_root = Path(os.environ['LINKEDSPEC_RUN_DIR'])
    assert os.environ['LINKEDSPEC_RUN_ACTIVE'] == '1' and run_root.resolve().is_relative_to(ROOT)
    with tempfile.TemporaryDirectory(prefix='publisher-controls-', dir=run_root) as name:
        module.LOGS = Path(name)
        if kind == 'collision':
            refs[temporary] = 'e' * 40
        if kind == 'wrong-main':
            refs[main_ref] = 'd' * 40
        if kind == 'resume':
            refs[temporary] = plan['batches'][4]['target']
            (module.LOGS / ('push-session-' + head[:12] + '.json')).write_text(json.dumps(
                dict(head=head, temporary_ref=temporary, initial_main=plan['remote_base'])))

        def git(*args):
            if args == ('status', '--porcelain'):
                return ''
            if args == ('rev-parse', 'HEAD'):
                return head
            if args == ('remote', 'get-url', '--push', '--all', 'origin'):
                return 'git@github.com:rdje/linkedspec.git'
            raise AssertionError('unexpected fixture Git command: ' + repr(args))

        def size(base, target):
            if kind == 'oversize' and target == plan['batches'][0]['target']:
                return plan['limit_bytes']
            return 1024

        def push(refspec, ref, expected, label, measured=None, lease=None):
            if ref == main_ref:
                assert refs.get(temporary) == head, 'main moved before the complete upload'
            if label == 'cleanup':
                assert lease == refs[temporary] and refs[main_ref] == head
            calls.append(label)
            refs[ref] = expected

        module.git = git
        module.remote_tip = refs.get
        module.pack_size = size
        module.push = push
        original_run = subprocess.run
        subprocess.run = lambda args, **kwargs: subprocess.CompletedProcess(args, 0)
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                try:
                    module.main()
                except AssertionError:
                    assert kind in ('collision', 'wrong-main', 'oversize')
                else:
                    assert kind in ('healthy', 'resume'), 'unsafe fixture admitted'
        finally:
            subprocess.run = original_run
        if kind in ('healthy', 'resume'):
            assert refs[main_ref] == head and refs[temporary] is None
            assert calls[-2:] == ['main', 'cleanup']
            assert len([label for label in calls if label.startswith('batch-')]) == len(plan['batches']) - (5 if kind == 'resume' else 0)
        else:
            assert refs[main_ref] == ('d' * 40 if kind == 'wrong-main' else plan['remote_base'])
            assert calls == (['seed'] if kind == 'oversize' else []), 'rejected plan sent a data batch'
    return kind


if __name__ == '__main__':
    print(json.dumps(dict(synthetic_protocol_controls=[scenario(name) for name in (
        'healthy', 'resume', 'oversize', 'wrong-main', 'collision')],
        limits='Synthetic operator control flow only; no real network push, receipt or GitHub size admission is claimed.')))
