"""Capture the finite, reviewed current-contract edits separately from prose reflow."""
import json
from pathlib import Path
import re
import subprocess

ROOT=Path(__file__).resolve().parents[3]
PREFIX=Path(__file__).parent


def normal(text):
    return re.sub(r'\s+',' ',text).strip()


def one(pattern,text):
    matches=re.findall(pattern,text)
    assert len(matches)==1,(pattern,len(matches))
    return matches[0]


def capture():
    destination=PREFIX/'book-edits.json'
    assert not destination.exists(),'retain prior edit epochs'
    local='docs/linkedspec-book/src/development/local-ci-and-regression.md'
    workflow='docs/linkedspec-book/src/development/documentation-workflow.md'
    patterns={local:[
        ('archive/reference roles',r'All four are now current bounded collections:.*?Their former debt ceilings remain historical facts rather than reusable growth allowances\.',r'Live status remains a bounded current view.*?exact old/new contracts in the accepted ADR\.'),
        ('normalized catalog interface',r'The chronology protocol uses a tracked JSONL manifest per family\.',r'The chronology protocol uses a tracked JSONL catalog root per family\..*?independent of physical paging\.'),
        ('TYPE current topology',r'Two task trees use stable semantic partitions\.',r'Three task trees use stable semantic partitions\..*?owning mutable part\.'),
        ('source/current partition distinction',r'Both strict indexes bind clean Git source identities/ranges and same-commit current counts/digests\.',r'The FUTURE and STARTUP indexes bind their original clean Git source identities/ranges.*?open bodies are preserved by the migration oracle\.'),
        ('composed metadata checks',r'the existing task metadata doctrine composes both registered partition validators and the repository-wide current-ID census\.',r'the task metadata doctrine composes the registered partition validators, source-bound narrative checker and repository-wide current-ID census\.')],
        workflow:[
        ('current verifier dependencies',r'adds `doctrine/readme_stability/routes.jsonl` and an unconditional core-Perl resulting-tree check\.',r'introduced `doctrine/readme_stability/routes.jsonl`.*?scope admission under ADR `0139`\.'),
        ('accepted lifecycle revision',r'That documentation-sustainability program is composition-closed\.',r'That documentation-sustainability program is composition-closed\..*?no temporary waiver or cap refresh is used\.'),
        ('public normalized reconstruction example',r"rows = Path\('docs/history/changes/manifest.jsonl'\).read_text\(\).splitlines\(\) row = json.loads\(rows\[1\]\)",r"rows = json.loads\(subprocess.check_output\(\[ 'perl', 'tools/read_document_history.pl', '--surface', 'change_history', '--catalog-json' \]\)\) row = rows\[1\]"),
        ('historical/current image stages',r'Missing, duplicated or changed additions and unrelated edits fail the audit\.',r'Missing, duplicated or changed additions and unrelated edits fail the audit\..*?under its existing owners\.')
    ]}
    result={}
    for name,cases in patterns.items():
        before=normal(subprocess.check_output(['git','show','HEAD:'+name],cwd=ROOT).decode().split('### Current document-pressure restoration')[0])
        after=normal((ROOT/name).read_text().split('### Current document-pressure restoration')[0])
        edits=[dict(reason=reason,before=one(old,before),after=one(new,after)) for reason,old,new in cases]
        restored=before
        for edit in edits:
            assert restored.count(edit['before'])==1
            restored=restored.replace(edit['before'],edit['after'],1)
        assert restored==after,'unreviewed Markdown word/token change: '+name
        result[name]=edits
    destination.write_text(json.dumps(dict(schema_version=1,books=result),indent=2,ensure_ascii=False)+'\n')
    print('book edits: only reviewed contract/API updates plus exact prose reflow')

if __name__=='__main__':capture()
