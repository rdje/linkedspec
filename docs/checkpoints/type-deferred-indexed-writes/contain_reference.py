"""Keep the existing document quotas with verified prose reflow and a shorter caption."""
import json
import pathlib
import re
import common as c

CHAPTER = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
CARD = 'docs/knowledge/write-vivification-perl-reference.md'


def reflow(text):
    assert '\r' not in text
    assert not re.search(r'(?im)^\s*<(?:pre|div|style|script|table|details|section|!--)', text), 'raw HTML needs separate treatment'
    output = []
    paragraph = []
    fence = None

    def flush():
        if paragraph:
            output.append(' '.join(paragraph))
            paragraph.clear()

    for line in text.split('\n'):
        marker = re.match(r'^\s*(`{3,}|~{3,})', line)
        if marker:
            flush()
            output.append(line)
            if fence is None:
                fence = marker[1][0]
            elif marker[1][0] == fence:
                fence = None
            continue
        ordinary = (not fence and re.match(r'^[A-Za-z0-9"`(]', line)
                    and not re.match(r'^\d+[.)]\s', line)
                    and '|' not in line and '<' not in line and '>' not in line
                    and not line.endswith(('  ', '\\')))
        if ordinary:
            paragraph.append(line)
        else:
            flush()
            output.append(line)
    flush()
    assert fence is None
    return '\n'.join(output)


def main():
    focused = c.load('focused5.json.gz')
    assert focused['run']['returncode'] == 0, 'finish semantic repair before changing book inputs'
    prior = c.load('book4.json.gz')
    before = {path: c.read(path) for path in (CHAPTER, CARD)}
    assert before[CHAPTER] == prior['inputs'][CHAPTER]
    text = c.decode(before[CHAPTER]['base64']).decode()
    changed = reflow(text)
    removed = text.count('\n') - changed.count('\n')
    assert removed >= 100, ('need enough quota headroom', removed)
    assert len(changed.encode()) <= len(text.encode())
    card = c.decode(before[CARD]['base64']).decode()
    assert card.count('Original FUTURE-PARITY-BACKLOG.19.2.1') == 1
    assert card.count('Full original card:') == 1
    shortened = card.replace('Original FUTURE-PARITY-BACKLOG.19.2.1',
                             'FUTURE-PARITY-BACKLOG.19.2.1', 1).replace('Full original card:', 'Prior card:', 1)
    shortened = shortened.replace('answers:\n', 'answers:\n  - "why is __ls_binding_presence undeclared in a Perl fragment"\n', 1)
    old_fragment = '''October19 isolated-fragment reminder: declare `my %__ls_binding_presence`
alongside value lexicals; a fixture with bound `meta = {}` marks meta present.
Native rule/function bodies supply that invocation-local map. Three standalone
compile failures are retained by TYPE-REFERENCE-BOOK.1.2.3 before its fixture repair.'''
    assert shortened.count(old_fragment) == 1
    shortened = shortened.replace(old_fragment, '''Standalone indexed/receiver-mutation fragments declare
`my %__ls_binding_presence` alongside value lexicals and mark bound roots
present. Plain assignment/read fragments add no presence-map requirement.
Compiled frames supply scalar flags. Three October19 fixture failures/fixes
remain in TYPE-REFERENCE-BOOK.1.2.3;12 preserves this fragment ABI.''', 1)
    old_history = '''Historical .19.2.1 proof: 5 AST/7 syntax/11 success/16 structural cases plus
kind, detachment, evaluation, re-entrancy, both null spellings, spans and functions;
ActionIR/trace/uniform50 and Phase0 1032/963s after12 stale expectations.
Other backends were pending .19.3-.6 at that Perl-only boundary.'''
    assert shortened.count(old_history) == 1
    shortened = shortened.replace(old_history, '''Historical .19.2.1: AST5/syntax7/success11/structural16;
ActionIR/trace/uniform50; Phase0 1032/963s after12 stale expectations.
Other backends awaited .19.3-.6; the prior Git card above retains full scope.''', 1)
    shortened = shortened.replace('Malformed records reject before\neffects.', 'Invalid write headers reject before effects.', 1)
    assert len(shortened.encode()) < len(card.encode()) - 10
    c.save('containment-before.json.gz', dict(
        epoch=c.epoch(), inputs=before, producer=c.read(c.PREFIX+'contain_reference.py'),
        observation=dict(command='bash scripts/check_readme_stability.sh',
                         source='Actual tool session 81348; excerpt transcribed from its completed exit-1 output, not a rerun.',
                         excerpt='[readme-routing] FAIL: surface knowledge_cards exceeds control: aggregate bytes 8388611/8388608\n[readme-routing] FAIL: surface public_reference exceeds control: aggregate lines 50049/50000\n')))
    (c.ROOT/CHAPTER).write_text(changed)
    (c.ROOT/CARD).write_text(shortened)
    path = c.ROOT/'docs/tasks/TYPE-REFERENCE-BOOK.md'
    tree = path.read_text()
    anchor = '  Remaining proof/landing:'
    start = tree.index(anchor, tree.index('- ID: `'+c.OWNER+'`'))
    tree = tree[:start] + ('  Containment repair owned here: The completed routing-pressure check rejected this candidate on Knowledge-card bytes and public-reference lines. containment-before.json.gz retains the actual output excerpt and full input epoch. Condense duplicated historical proof prose into its existing real-Git pointer, retain all historical counts, and record the compiled/standalone presence boundary. Reflow ordinary paragraphs in the already affected chapter; retain every code fence and prove the full rendered page against the pre-reflow book4 output. Existing quotas stay unchanged. book5 supplies an actual prose-word corruption as well as the heading control.\n') + tree[start:]
    path.write_text(tree)
    original = (c.ROOT/c.PREFIX/'book4.py').read_text()
    script = original.replace('book4', 'book5')
    script = script.replace('import common as c', 'from html.parser import HTMLParser\nimport common as c')
    marker = '\ndef main():\n'
    assert script.count(marker) == 1
    helpers = '''
class PageSignature(HTMLParser):
 def __init__(self):
  super().__init__(convert_charrefs=True)
  self.tokens=[]
  self.literal=0
 def handle_starttag(self,tag,attrs):
  self.tokens.append(('open',tag,sorted(attrs)))
  if tag in ('pre','code','script','style'):self.literal+=1
 def handle_endtag(self,tag):
  self.tokens.append(('close',tag))
  if tag in ('pre','code','script','style'):self.literal-=1
  assert self.literal>=0
 def handle_data(self,data):
  self.tokens.append(('text',data if self.literal else re.sub(r'[ \\t\\r\\n\\f]+',' ',data)))
 def handle_comment(self,data):self.tokens.append(('comment',data))
 def handle_decl(self,data):self.tokens.append(('declaration',data))
 def handle_pi(self,data):self.tokens.append(('instruction',data))
def signature(run):
 parser=PageSignature()
 parser.feed(c.decode(run['page_base64']).decode())
 parser.close()
 assert parser.literal==0
 return parser.tokens
'''
    script = script.replace(marker, '\n'+helpers+marker, 1)
    old = ' healthy=render(supplied);changed=render(supplied,True)'
    assert script.count(old) == 1
    script = script.replace(old, old+'''
 prior=c.load('book4.json.gz')
 raw=c.decode(supplied[CHAPTER]['base64'])
 needle=b'Perl callable bodies accept'
 assert raw.count(needle)==1
 poisoned=raw.replace(needle,b'Perl callable bodies reject',1)
 override=dict(base64=c.encode(poisoned),sha256=c.sha(poisoned),mode=supplied[CHAPTER]['mode'])
 prose_inputs={**supplied,CHAPTER:override}
 prose_changed=render(prose_inputs)
 comparison=dict(prior='book4.json.gz',same=signature(healthy)==signature(prior['healthy']),prose_red=signature(prose_changed)!=signature(prior['healthy']))
''', 1)
    old = 'context=context,inputs=supplied,plan=plan,public=public,healthy=healthy'
    assert script.count(old) == 1
    script = script.replace(old, 'context=context,inputs=supplied,plan=plan,public=public,comparison=comparison,prose_override={CHAPTER:override},prose_changed=prose_changed,healthy=healthy', 1)
    old = " assert not c.failures(public,plan),c.failures(public,plan)"
    script = script.replace(old, old+"\n assert comparison['same'] and comparison['prose_red'],comparison", 1)
    (c.ROOT/c.PREFIX/'book5.py').write_text(script)
    path = c.ROOT/c.PREFIX/'review.py'
    review = path.read_text().replace('import book4 as book','import book5 as book').replace("c.load('book4.json.gz')", "c.load('book5.json.gz')")
    old = " rendered=c.load('book5.json.gz')"
    assert review.count(old) == 1
    review = review.replace(old, old+"\n prior_book=c.load('book4.json.gz')\n assert book.signature(rendered['healthy'])==book.signature(prior_book['healthy'])\n assert book.signature(rendered['prose_changed'])!=book.signature(prior_book['healthy'])", 1)
    path.write_text(review)
    path = c.ROOT/c.PREFIX/'publish.py'
    publication = path.read_text().replace('The removed rendered heading rejects.', 'The removed rendered heading rejects. Ordinary paragraph reflow preserves the complete prior rendered page signature; an actual supplied prose-word mutation changes the page and rejects.')
    path.write_text(publication)
    path = c.ROOT/c.PREFIX/'finalize.py'
    finalizer = path.read_text().replace('exact examples/heading RED;', 'exact examples/heading and prose RED;')
    path.write_text(finalizer)
    c.save('containment-after.json.gz', dict(inputs={path:c.read(path) for path in (CHAPTER,CARD)},removed_source_lines=removed,removed_card_bytes=len(card.encode())-len(shortened.encode()),producer=c.read(c.PREFIX+'contain_reference.py')))
    print('Containment edits prepared; rendered equivalence still requires book5:',removed,'source lines reflowed')

if __name__ == '__main__':
    main()
