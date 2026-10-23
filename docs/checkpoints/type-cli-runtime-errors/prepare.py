"""Freeze independent failure/falsey controls and the unmodified public probe."""
from pathlib import Path
import common as c


def main():
    cases = []
    def case(name,body,**fields):
        cases.append(dict(id=name,source='Top: /x/\n I { '+body+' }\n',input='x',**fields))
    case('fractional-write','items=[10,20,30]; items[1.5]=99; return(items)',error='nested_write_segment_invalid')
    case('callable-fractional-write','items=[10,20,30]; cb={|| items[1.5]=99; return(items) }; return(cb())',error='nested_write_segment_invalid')
    case('wrong-container','items=[10]; items["x"]=99; return(items)',error='nested_write_kind_conflict')
    case('thrown-exit','exit_now(7)',exception='LinkedSpec::RuntimeExitNow')
    case('valid-null','return(undef)',value=None)
    case('valid-false','return(false)',value=False)
    case('valid-zero','return(0)',value=0)
    case('valid-array','return([10,20,30])',value=[10,20,30])
    case('no-match','return(42)',value=None)
    cases[-1]['input']='y'
    c.write_new('cases.json',dict(cases=cases,
        scope='Three context-only failures; one thrown error; five legitimate result/no-match controls. Existing CLI invocation-failure protocol, no selector-policy change.'))
    (c.ROOT/c.PREFIX/'perl_probe.pl').write_bytes((c.ROOT/'docs/checkpoints/signed-array-selectors/perl_probe.pl').read_bytes())
    print('Nine exact CLI/library sources frozen; public probe reused byte-exact')


if __name__ == '__main__':
    main()
