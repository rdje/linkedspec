"""Retain each custody census before any recovery adjustment."""
import argparse
import common as c
import context


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--epoch',required=True);args=parser.parse_args()
    assert args.epoch.replace('-','').isalnum()
    extras=[c.PREFIX+path.name for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    extras+=['tests/drop-generated/cases.json','tests/drop-generated/book-cases.json','t/drop_keys_generated.t',
             'tests/language-readiness/drop-generated-regression-evolution.json.gz']
    snapshot=context.snapshot(extras)
    c.write_new(args.epoch+'-inputs.json.gz',snapshot)
    run=c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'custody.py'])
    unchanged=c.unchanged(snapshot['inputs'])
    c.write_new(args.epoch+'-run.json.gz',dict(run=run,inputs_unchanged=unchanged))
    assert unchanged
    print('Custody census',args.epoch,'exit',run['returncode'])


if __name__=='__main__':main()
