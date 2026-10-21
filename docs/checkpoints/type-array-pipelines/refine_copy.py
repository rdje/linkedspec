"""Test pure results through supported caller-side mutation, preserving both rejected plans."""
import common as c

def main():
    plan=c.load('cases2.json')
    for case in plan['cases']:
        if case['id'] in ('deferred/sorted/copy','deferred/take/copy'):
            expression='sorted(items)' if '/sorted/' in case['id'] else 'take(items,2)'
            case['body']='items = ["b","a","c"]; cb = {|| return('+expression+') }; out = cb(); out[0] = "z"; return([items,out])'
    plan['scope']+=' Second85 epoch rejects unsupported deferred assign_nested_access;12 owns that separate write family. Caller-side indexed mutation proves independent selection results in the final plan.'
    c.write_new('cases3.json',plan)
    c.write_new('copy-refinement.json.gz',dict(producer=c.read(c.PREFIX+'refine_copy.py'),before=c.read(c.PREFIX+'cases2.json'),after=c.read(c.PREFIX+'cases3.json')))

if __name__=='__main__':main()
