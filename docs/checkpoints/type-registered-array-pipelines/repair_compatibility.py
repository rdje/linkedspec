"""Restore existing selector rejection before the synthetic bridge runs."""
import common as c

def main():
    assert len(c.load('compatibility-red.json.gz')['failures'])==2
    path=c.SOURCES[0]
    before=c.read(path)
    raw=c.decode(before['base64']).decode()
    old="   return 'undef' if $method eq 'length' && (@$aggregate_args || $index < $#$calls);"
    new="   if ($method eq 'count' || $method eq 'first' || $method eq 'length') {\n    return 'undef' if @$aggregate_args || $index < $#$calls;\n   }"
    assert raw.count(old)==1
    c.write_new('compatibility-repair-before.json.gz',dict(source=before,old=old,new=new,
        context=c.epoch(),producer=c.read(c.PREFIX+'repair_compatibility.py')))
    c.source(path).write_text(raw.replace(old,new,1))
    c.write_new('compatibility-repair.json.gz',dict(before=before,after=c.read(path),old=old,new=new))
    print('Existing count/first shape/terminal rejection restored to shared preflight')

if __name__=='__main__':main()
