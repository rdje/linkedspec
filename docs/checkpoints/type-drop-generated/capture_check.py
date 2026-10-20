"""Capture focused Phase0 or isolated historical proof with complete input custody."""
import argparse
import json
import re
import common as c
import context

ACTOR = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-focused.pl'
PROOF = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
PLAN = dict(selected=[
    dict(number=735,name='emit_context_lowers_value_layer_emptiness_helpers'),
    dict(number=759,name='emit_context_lowers_drop_keys_value_helpers'),
    dict(number=760,name='method_like_fluent_and_structured_action_drop_keys_value_helpers_lower_equivalently'),
    dict(number=761,name='method_like_fluent_and_structured_lifecycle_drop_keys_value_helpers_lower_equivalently'),
],ordinary_root_tests=1035)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--kind',choices=['historical','phase0'],required=True)
    parser.add_argument('--epoch',required=True)
    args = parser.parse_args()
    assert re.fullmatch(r'[a-z0-9-]+',args.epoch)
    extras = [c.PREFIX+path.name for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    extras += ['tests/drop-generated/cases.json','t/drop_keys_generated.t']
    snapshot = context.snapshot(extras)
    snapshot.update(plan=PLAN,kind=args.kind)
    c.write_new(args.epoch+'-inputs.json.gz',snapshot)
    result = c.run(['perl','-Iperl',ACTOR],input=json.dumps(PLAN).encode()) if args.kind=='phase0' else c.run([
        'bash','tools/run_python_project_data.sh',PROOF])
    unchanged = c.unchanged(snapshot['inputs'])
    c.write_new(args.epoch+'-run.json.gz',dict(run=result,inputs_unchanged=unchanged))
    assert unchanged
    print(args.kind,args.epoch,'exit',result['returncode'],'; full inputs',len(snapshot['inputs']))


if __name__ == '__main__':
    main()
