"""Complete the still-unexecuted post-repair targets after fixture qualification."""
import json
import common as c


def main():
    selected=[('bridge-after','linkedspec-runtime','test','numeric_bridge_contract'),
        ('runtime-library-after','linkedspec-runtime','lib','linkedspec_runtime'),
        ('core-library-after','linkedspec-core','lib','linkedspec_core'),
        ('core-types-after','linkedspec-core','test','types_test')]
    completed=[]
    for label,package,kind,target in selected:
        run=c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'run_suite.py',
            label,package,kind,target])
        c.save(label+'-producer-run.json.gz',run)
        print(label,'capture producer exit',run['returncode'],flush=True)
        assert run['returncode']==0
        assert c.load(label+'-run.json.gz')['run']['returncode']==0,label
        completed.append(label)
        (c.ROOT/'.linkedspec-data/verification/numeric55-remaining-after.json').write_text(
            json.dumps(dict(completed=completed,remaining=[row[0] for row in
                selected[len(completed):]]),indent=2)+'\n')
    c.save('remaining-after-result.json.gz',dict(selected=selected,completed=completed))


if __name__ == '__main__':
    main()
