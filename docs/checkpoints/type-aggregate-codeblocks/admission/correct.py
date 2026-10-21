"""Repair only prose layout under the existing public-reference limit."""
from pathlib import Path
import re
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c

CHAPTER='docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'


def fences(text):
    regions=[];active=None;buffer=[]
    for line in text.splitlines(keepends=True):
        match=re.match(r'^\s*(`{3,}|~{3,})',line)
        if active is None and match:
            active=match[1];buffer=[line]
        elif active is not None:
            buffer.append(line)
            if match and match[1][0]==active[0] and len(match[1])>=len(active):
                regions.append(''.join(buffer));active=None;buffer=[]
    assert active is None
    return regions


def reflow(text):
    lines=text.splitlines(keepends=True);out=[];active=None;index=0
    def plain(line):
        return (line.strip() and not line.startswith(('  ','\t'))
            and not re.match(r'^\s*(?:#|>|\||[-*+]\s|\d+\.\s|```|~~~|\{\{|<|\[[^]]+\]:|---|___|\*\*\*)',line)
            and not line.rstrip('\r\n').endswith(('  ','\\')))
    while index<len(lines):
        line=lines[index];match=re.match(r'^\s*(`{3,}|~{3,})',line)
        if match:
            if active is None:active=match[1]
            elif match[1][0]==active[0] and len(match[1])>=len(active):active=None
            out.append(line);index+=1;continue
        if active is None and index+1<len(lines) and plain(line) and plain(lines[index+1]):
            following=lines[index+1]
            ending='\r\n' if following.endswith('\r\n') else '\n' if following.endswith('\n') else ''
            out.append(line.rstrip('\r\n')+' '+following.rstrip('\r\n')+ending);index+=2
        else:out.append(line);index+=1
    result=''.join(out)
    assert fences(result)==fences(text)
    assert re.sub(r'\s+','',result)==re.sub(r'\s+','',text)
    return result


def main():
    first=c.load('admission/first.json.gz')
    assert c.unchanged(first['inputs'])
    paths=[CHAPTER,c.PREFIX+'review.py',c.PREFIX+'custody.py',c.PREFIX+'doc_proof.py',
        'docs/knowledge/terse-type-method-surface-inventory.md','MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md',
        'docs/tasks/TYPE-REFERENCE-BOOK.md','docs/TASK_TREE.md',c.PREFIX+'README.md']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    old=after[CHAPTER];new=reflow(old)
    reduction=old.count('\n')-new.count('\n')
    assert reduction>=8 and 50007-reduction<50000,reduction
    after[CHAPTER]=new
    path=c.PREFIX+'review.py'
    assert after[path].count('def check(fresh=True):')==1
    after[path]=after[path].replace('def check(fresh=True):','def check(fresh=True,doc_stem="doc"):',1)
    needle="    doc=c.load('doc-run.json.gz');inputs=c.load('doc-inputs.json.gz')"
    assert after[path].count(needle)==1
    after[path]=after[path].replace(needle,"    doc=c.load(doc_stem+'-run.json.gz');inputs=c.load(doc_stem+'-inputs.json.gz')",1)
    path=c.PREFIX+'custody.py'
    needle="        'artifact-epoch.json.gz']"
    assert after[path].count(needle)==1
    after[path]=after[path].replace(needle,"        'artifact-epoch.json.gz','admission/doc-inputs.json.gz']",1)
    path=c.PREFIX+'doc_proof.py'
    after[path]=after[path].replace('import json\n','import json\nimport sys\n',1)
    after[path]=after[path].replace('def main():\n','def main():\n    stem=sys.argv[1] if len(sys.argv)>1 else "doc"\n    assert stem in ("doc","admission/doc")\n',1)
    after[path]=after[path].replace("'doc-inputs.json.gz'","stem+'-inputs.json.gz'").replace("'doc-run.json.gz'","stem+'-run.json.gz'")
    path='docs/knowledge/terse-type-method-surface-inventory.md'
    needle=c.PREFIX+'publish.py'
    assert after[path].count(needle)==1
    after[path]=after[path].replace(needle,c.PREFIX+'publish_final.py',1)
    path='docs/tasks/TYPE-REFERENCE-BOOK.md'
    after[path]=after[path].replace('  Status: `done` / bounded Perl availability','  Status: `in_progress` / public-reference pressure admission',1)
    start=after[path].index('- ID: `'+c.OWNER+'`\n');end=after[path].index('- ID: `TYPE-REFERENCE-BOOK.1.2.9`\n',start)
    node=after[path][start:end]
    node=node.replace('  - [x] **NO REGRESSION**','  - [ ] **NO REGRESSION**').replace('  - [x] **LOCKSTEP**','  - [ ] **LOCKSTEP**')
    node+='  Admission owner: README pressure rejects public_reference50007/50000. Whole first10496 publication/actual readonly0/full modes/10499 Git-verified staged images survive before changes. Reflow prose only, preserve every non-whitespace character/fence and require rendered semantic identity; no budget increase. Failed old preflight intentionally joined143. Corrected book/proof/canonical landing remain required.\n\n'
    after[path]=after[path][:start]+node+after[path][end:]
    after[path]=after[path].replace('| `'+c.OWNER+'` | `done` | Bounded aggregate availability; owned pipeline9 next. |',
        '| `'+c.OWNER+'` | `in_progress` | Public-reference pressure admission; pipeline9 follows clean landing. |',1)
    after['docs/TASK_TREE.md']=after['docs/TASK_TREE.md'].replace('`active` / aggregate .1.2.7 done; pipeline .1.2.9 next',
        '`active` / aggregate .1.2.7 pressure admission; .1.2.9 next',1)
    after['LIVE_ACHIEVEMENT_STATUS.md']=after['LIVE_ACHIEVEMENT_STATUS.md'].replace(
        c.OWNER+' completes bounded Perl aggregate availability; deferred sorted/take pipeline .1.2.9 is next from clean Git.',
        c.OWNER+' behavior proof is verified; public-reference pressure admission remains in progress. Pipeline9 follows its clean canonical commit.',1)
    after['MEMORY.md']=f'''# MEMORY

- activation_commit: `{c.BASE}` — derive current HEAD from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.6` — latest committed unit; aggregate7 remains in flight.
- active_work_unit: `{c.OWNER}` (public-reference pressure admission); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: Stage corrected controlled surfaces; run routing-pressure --report, fresh admission/doc proof and normalized rendered-page comparison. Final publication/handoff/canonical/normal commit follow. No pivot to9 while dirty.
- in_flight_uncommitted: Aggregate7 code/tests/book/evidence and pressure repair. All runtime/source faults are restored. Old failed preflight is joined143; no canonical job has started. First draft is not an accepted Git revision.
- current_proof:214/106 RED/108 controls; seven actual runtime faults/restorations; final14/1948;201+3 permanent/15 malformed; initial book89/3. Runtime proof is unchanged. First public_reference50007/50000 RED is retained; prose reflow is lossless with code fences unchanged.
- custody: admission/first.json.gz retains complete first claim/publication/10496 inputs/full modes, actual readonly0 and10499 independently Git-verified source images. Plain changed sources have whole packets; immutable artifacts stay hash-gated; unchanged bytes recover from real efad. Whole prior drop10334 remains intact.
- checkpoint: {c.PREFIX}admission/; final readonly publisher will be publish_final.py. Preserve first publish.py/publication/manifest unchanged; replay them only with recorded inputs.
- known_kind95: Three real index failures/two scalar controls/B flags remain owned. Actual old192-input library/65 loaded owners is byte-verified and restored; initial shadows are rejected. Original95 instrument/environment is unretained; no95 fix here.
- next_owned: pipeline9 -> inventory1 -> book mapping2 -> layout3 -> legacy8 -> metadata QA13 -> references/closeout. Startup20/32/35/87.4 and constructor94 remain owned.
- cleanup: Latest2026-10-20T19:45:58.736082+00:00; less than24h. Frozen old cache/source images remain required inputs.
- standing_limit: Other repositories and RGX/PGEN are read-only black boxes. Project data stays on this volume. No budget or verification profile is weakened; no push yet.
'''
    after[c.PREFIX+'README.md']+='''
Pressure admission: the first10496-input publication/actual readonly0 and10499
Git-verified staged images are retained whole in admission/first.json.gz. The
old preflight failed public_reference50007/50000 and was deliberately joined143
before changes. Prose reflow preserves every non-whitespace character and every
code fence; final rendered identity/pressure proof and exact canonical gate are
required. First publish.py is an unpublished historical draft: restore its
recorded source inputs before replay. Current rederive becomes publish_final.py.
'''
    for path,text in after.items():
        if path.endswith('.py'):compile(text,path,'exec')
    c.write_new('admission/correction.json.gz',dict(before=before,
        after={path:c.encode(text.encode()) for path,text in after.items()},
        lines_reduced=reduction,predicted_public_reference_lines=50007-reduction,
        code_fences_unchanged=True,non_whitespace_unchanged=True,
        producer=c.read(c.PREFIX+'admission/correct.py'),
        scope='Only public chapter prose layout changes; runtime/tests and actual example bytes stay '
              'exact. Extend readers for a distinct corrected book epoch without refreshing old data. '
              'Reopen admission metadata and route the current fact to a new final publisher.'))
    for path,text in after.items():(c.ROOT/path).write_text(text)
    print('Lossless prose reflow:',reduction,'lines removed; predicted public_reference',50007-reduction,'/50000')


if __name__=='__main__':main()
