"""Run complete post-repair captures sequentially against frozen Rust inputs."""
import json
import common as c


def main():
    selected = [
        ('core-after-complete','linkedspec-core','test','numeric_conversion_contract'),
        ('runtime-after','linkedspec-runtime','test','numeric_conversion_contract'),
        ('bridge-after','linkedspec-runtime','test','numeric_bridge_contract'),
        ('runtime-library-after','linkedspec-runtime','lib','linkedspec_runtime'),
        ('core-library-after','linkedspec-core','lib','linkedspec_core'),
        ('core-types-after','linkedspec-core','test','types_test'),
    ]
    completed = []
    for label, package, kind, target in selected:
        run = c.run(['bash','tools/run_python_project_data.sh',
            c.PREFIX+'run_suite.py',label,package,kind,target])
        c.save(label+'-producer-run.json.gz',run)
        print(label,'capture producer exit',run['returncode'],flush=True)
        assert run['returncode']==0
        result = c.load(label+'-run.json.gz')
        assert result['run']['returncode']==0, label+' actual test failure retained'
        completed.append(label)
        path = c.ROOT/'.linkedspec-data/verification/numeric55-after-sequence.json'
        path.write_text(json.dumps(dict(owner=c.OWNER,completed=completed,
            remaining=[row[0] for row in selected[len(completed):]]),indent=2)+'\n')
    c.save('after-sequence-result.json.gz',dict(selected=selected,completed=completed))
    print('All selected complete post-repair targets pass.',flush=True)


if __name__ == '__main__':
    main()
