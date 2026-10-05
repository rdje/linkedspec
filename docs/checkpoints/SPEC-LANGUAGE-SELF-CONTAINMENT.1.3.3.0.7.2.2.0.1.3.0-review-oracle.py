"""Author Flow cases and scalar intervals from literal fragments, never scan output."""
from pathlib import Path
import json

PREFIX = __file__.removesuffix('review-oracle.py')
IDS = ['if_flow','elseif_flow','else_flow','endif_flow','while_flow','switch_flow',
       'case_flow','default_flow','endcase_flow','endswitch_flow','say_stmt',
       'print_each','print_stmt','exit_now','next_stmt','return_undef']


class Source:
    def __init__(self):
        self.text = ''
        self.marks = {}

    def add(self, text, name=None, args=None):
        start = len(self.text)
        self.text += text
        if name:
            self.marks[name] = {'raw': text, 'args': args or {},
                                'start': start, 'end': len(self.text)}

    def wrap(self, name, head, body, args=None):
        start = len(self.text)
        self.add(head)
        body(self)
        self.add(' }')
        self.marks[name] = {'raw': self.text[start:], 'args': args or {},
                            'start': start, 'end': len(self.text)}


def author():
    s = Source()
    s.add('note("雪😀");\r\n')
    forms = [
        ('if_flow','if(true) { say("a") }',{'condition':'true'}),
        ('elseif_flow','elseif(false) { print("b") }',{'condition':'false'}),
        ('else_flow','otherwise { next }',{}),('endif_flow','endif',{}),
        ('while_flow','while(false) { next() }',{'condition':'false'}),
        ('switch_flow','switch(kind) { case("a") { print_each(items) } default { exit_now() } }',{'expr':'kind'}),
        ('endcase_flow','endcase',{}),('endswitch_flow','endswitch',{}),
        ('say_stmt','say("x", 3)',{'values':['"x"','3']}),
        ('print_stmt','print("y")',{'values':['"y"']}),
        ('print_each','print_each(items)',{'target':'items'}),
        ('exit_now','exit_now(7)',{'payload':'7'}),('next_stmt','next',{}),
        ('return_undef','return_undef()',{'value':'undef'})]
    # Independent per-contract source excludes incidental nested helper matches.
    cases = []
    for contract, raw, args in forms:
        x = Source(); x.add('note("雪😀");\r\n'); x.add(raw, 'first', args)
        x.add(';\r\n'); x.add(raw, 'second', args)
        cases.append({'id':contract,'action':x.text,'contracts':[contract],
                      'expected':{contract:[x.marks['first'],x.marks['second']]}})
    # Blocks recurse depth first; marker and inline passes are concatenated.
    r = Source(); r.add('note("雪😀");\r\n')
    def inner(x):
        x.add(' ')
        def deep(y):
            y.add(' '); y.add('case("deep")','deep',{'value':'"deep"'}); y.add(';')
        x.wrap('inner','case("inner") {',deep,{'value':'"inner"'}); x.add(';')
    r.wrap('outer','case("outer") {',inner,{'value':'"outer"'}); r.add('; ')
    def middle(x):
        x.add(' ')
        def leaf(y): y.add(' '); y.add('default','leaf'); y.add(';')
        x.wrap('middle','default {',leaf); x.add(';')
    r.wrap('root','default {',middle); r.add(';\r\n')
    start = len(r.text); r.add('switch(kind, ')
    branch_start = len(r.text); r.add('case("inline", ')
    r.add('case("nested")','nested',{'value':'"nested"'}); r.add(', ')
    r.add('case("twin")','inline-twin',{'value':'"twin"'}); r.add(')')
    r.marks['inline']={'raw':r.text[branch_start:],'args':{'value':'"inline"'},'start':branch_start,'end':len(r.text)}
    r.add(', '); default_start=len(r.text); r.add('default(')
    r.add('default()','inline-default1');r.add(', ');r.add('default()','inline-default2');r.add(')')
    r.marks['inline-default']={'raw':r.text[default_start:],'args':{},'start':default_start,'end':len(r.text)}
    r.add(')');r.marks['switch']={'raw':r.text[start:],'args':{'expr':'kind'},'start':start,'end':len(r.text)}
    r.add('; ');r.add('case("twin")','tail-case',{'value':'"twin"'});r.add('; ');r.add('default()','tail-default')
    cases.append({'id':'recursive','action':r.text,'contracts':IDS,
                  'expected':{id:[r.marks[name] for name in names] for id,names in {
                      'switch_flow':['switch'],
                      'case_flow':['outer','inner','deep','tail-case','inline','nested','inline-twin'],
                      'default_flow':['root','middle','leaf','tail-default','inline-default','inline-default1','inline-default2']}.items()}})
    # Whitespace, discarded empty CSV slots, quoted twins, and repeated arguments.
    a=Source();a.add('switch(kind,  ');begin=len(a.text)
    a.add('case("a", say("')
    a.add('case(\\"quoted\\")")','quoted',{'value':'\\"quoted\\")"'})
    a.add(', ')
    a.add('case("a")','nested',{'value':'"a"'});a.add(')')
    a.marks['inline']={'raw':a.text[begin:],'args':{'value':'"a"'},'start':begin,'end':len(a.text)}
    a.add(' , , default(');begin=len(a.text)-len('default(')
    a.add('default()','d1');a.add(', ');a.add('default()','d2');a.add(')')
    a.marks['default']={'raw':a.text[begin:],'args':{},'start':begin,'end':len(a.text)}
    a.add(')')
    cases.append({'id':'arguments','action':a.text,'contracts':['case_flow','default_flow'],
                  'expected':{'case_flow':[a.marks['inline'],a.marks['quoted'],a.marks['nested']],
                              'default_flow':[a.marks['default'],a.marks['d1'],a.marks['d2']]}})
    return cases


if __name__ == '__main__':
    Path(PREFIX+'review-cases.json').write_text(json.dumps(author(),ensure_ascii=False,indent=2)+'\n')
