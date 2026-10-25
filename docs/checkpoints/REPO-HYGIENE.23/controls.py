"""One-shot actual reviewer commands and distinguishing RED controls."""
import common as c


def main():
    supplied=c.snapshot()
    c.save('review-controls-inputs.json.gz',supplied)
    command=['python3',c.PREFIX+'review.py','--control']
    runs={}
    for name in ('healthy','part-bytes','part-mode','missing-part','wrong-total','wrong-value','denied-inspection'):
        runs[name]=c.run(command+[name])
        c.save('review-control-'+name+'.json.gz',runs[name])
        if name=='healthy':assert runs[name]['returncode']==0
        else:assert runs[name]['returncode']!=0 and b'AssertionError' in c.decode(runs[name]['stderr_base64'])
        print('Actual review control:',name,'exit',runs[name]['returncode'],flush=True)
    restored=c.run(command+['healthy']);c.save('review-restored.json.gz',restored)
    assert restored['returncode']==0 and restored['stdout_base64']==runs['healthy']['stdout_base64']
    assert c.unchanged(supplied['inputs'])
    c.save('review-controls.json.gz',dict(red_controls=6,healthy_and_restored_pass=True,
        unchanged_inputs=True,
        initial_instrument_failure=c.read('.linkedspec-data/verification/hygiene23-review-initial.log'),
        qualification='The initial reviewer assumed the quarantine recheck was a nested object; its retained diagnostic is an instrument correction, not product RED. The corrected actual healthy run precedes six distinguishing denials; final restoration is byte-identical.'))


if __name__=='__main__':main()
