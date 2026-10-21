"""Retain rejected fact pressure and shorten only the existing kind summary."""
import common as c


def main():
    path=c.PREFIX+'final_prechecks.py'
    before=c.read(path)
    run=c.run(['bash','tools/run_python_project_data.sh',path])
    assert run['returncode']!=0 and b'AssertionError: 8388722' in c.decode(run['stderr_base64'])
    raw=c.decode(before['base64']).decode()
    raw=raw.replace("    text=text.replace('Observed','Observed')\n",'')
    raw='\n'.join(line for line in raw.split('\n') if ' if False else text' not in line)
    anchor="    total=sum(path.stat().st_size for path in (c.ROOT/'docs/knowledge').glob('*.md'))"
    addition='''    old_summary="""docs/checkpoints/type-aggregate-codeblocks/ retains raw channels, full source
epochs/restorations, direct JSON independent of projection, B flags and actual
public index failures.95 remains after93/92/94 before51: audit aggregate authority,
repair internal numeric kinds and add kind-sensitive recurrence. No95 fix or all-input/backend admission follows from7."""
    compact="""Evidence: docs/checkpoints/type-aggregate-codeblocks/ (raw channels, source bytes,
loaded owners, flags and public failures).95 stays after93/92/94 before51: audit
aggregate inputs and repair kinds with consumer recurrence. No95 fix/backend
admission from7."""
    assert after[kind].count(old_summary)==1
    after[kind]=after[kind].replace(old_summary,compact,1)
'''
    assert raw.count(anchor)==1
    after=raw.replace(anchor,addition+anchor,1)
    c.write_new('final-prechecks-pressure.json.gz',dict(before=before,run=run,after_base64=c.encode(after.encode()),
        scope='Rejected before writes. Shorten existing kind summary without losing evidence/priority '
              'or increasing the budget; remove two inert proposal-editing lines.'))
    (c.ROOT/path).write_text(after)


if __name__=='__main__':main()
