"""Remove the final argument guard in its actual owner, observe public RED, restore."""
import common as c
import malformed

def main():
    change=c.load('argument-guard-change.json.gz');source=c.read(c.SOURCE)
    assert source['base64']==change['after'][c.SOURCE]
    text=c.decode(source['base64']).decode();assert text.count(change['new'])==1
    mutant=text.replace(change['new'],change['old'],1).encode()
    healthy=c.run(['perl','-Iperl',c.PREFIX+'malformed.pl'])
    try:
        (c.ROOT/c.SOURCE).write_bytes(mutant)
        red=c.run(['perl','-Iperl',c.PREFIX+'malformed.pl'])
        c.write_new('guard-fault-observed.json.gz',dict(source=c.read(c.SOURCE),run=red,
            producer=c.read(c.PREFIX+'guard_fault.py')))
    finally:
        (c.ROOT/c.SOURCE).write_bytes(c.decode(source['base64']))
        (c.ROOT/c.SOURCE).chmod(source['mode'])
    restored=c.run(['perl','-Iperl',c.PREFIX+'malformed.pl'])
    c.write_new('guard-fault-run.json.gz',dict(healthy=healthy,red=red,restored=restored,source_restored=c.read(c.SOURCE)==source))
    assert malformed.typed(healthy) and not malformed.typed(red) and malformed.typed(restored)
    assert c.read(c.SOURCE)==source
    print('Final15 typed malformed cases; actual guard removal RED; exact restoration')

if __name__=='__main__':main()
