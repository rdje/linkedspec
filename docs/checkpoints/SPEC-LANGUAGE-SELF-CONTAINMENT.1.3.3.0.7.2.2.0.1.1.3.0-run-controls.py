"""Observe that an actual post-run input failure retains the completed channels."""
from pathlib import Path
import importlib.util
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('run-controls.py')
spec = importlib.util.spec_from_file_location('fixed_runner', PREFIX + 'run.py')
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)
original_verify = runner.review.verify_tree
calls = 0


def alter_after_completed_consumer(tree, manifest):
    global calls
    calls += 1
    if calls == 2:
        (tree / 'conf/unretained.conf').write_bytes(b'controlled extra input\n')
    return original_verify(tree, manifest)


runner.review.verify_tree = alter_after_completed_consumer
output = Path(PREFIX + 'control-run.json')
sys.argv = ['run.py', '--mode', 'smoke', '--output', output.relative_to(ROOT).as_posix()]
try:
    runner.main()
except ValueError as error:
    runner.review.check(str(error) == 'runtime input directory population', 'actual post-run failure reason')
    result = json.loads(output.read_bytes())
    runner.review.check(not result['complete'] and len(result['rows']) == 1, 'failed run cannot claim completion')
    row = result['rows'][0]
    runner.review.check(row['input_check_failure'] == str(error), 'failure and actual consumer output retained together')
    count = runner.review.verify_tap(row)
    report = {'control': 'add an actual unretained input after the first completed consumer',
              'reason': str(error), 'observed_rejection': True, 'retained_complete_tap_tests': count,
              'failed_run_report': output.relative_to(ROOT).as_posix(),
              'instrument': {'path': Path(__file__).relative_to(ROOT).as_posix(),
                             'sha256': runner.review.sha(Path(__file__).read_bytes())}}
    Path(PREFIX + 'run-controls.json').write_text(json.dumps(report, indent=2) + '\n')
    print('PASS observed post-run input RED; completed 13-group TAP and both channels remain saved')
else:
    raise ValueError('actual post-run input corruption accepted')
