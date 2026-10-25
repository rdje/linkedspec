"""Run the remaining dependent and historical checks after all source restoration."""
import json
import common as c


def main():
    for name in ['json-clamp','host-bound','roundtrip','signed-zero','definition-field']:
        assert c.load('fault-first-'+name+'-result.json.gz')['exact_source_restored']
    assert not (c.ROOT/'.linkedspec-data/verification/numeric55-source-fault-lease.json').exists()
    selected=['broad_compatibility2.py','fresh_readiness.py','history_final.py','auditor_controls.py']
    completed=[]
    for script in selected:
        result=c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+script])
        c.save('closeout2-'+script[:-3]+'-run.json.gz',result)
        print('Closeout',script,'actual exit',result['returncode'],flush=True)
        assert result['returncode']==0,script+' actual failure retained'
        completed.append(script)
        (c.ROOT/'.linkedspec-data/verification/numeric55-closeout2.json').write_text(
            json.dumps(dict(completed=completed,remaining=selected[len(completed):]),indent=2)+'\n')
    c.save('closeout2-result.json.gz',dict(completed=completed))


if __name__=='__main__':main()
