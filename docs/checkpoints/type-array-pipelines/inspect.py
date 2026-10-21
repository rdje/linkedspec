"""Preserve unexpected public results and inspect their exact emitted mechanism."""
import json
import common as c

def main():
    saved=c.load('candidate1-run.json.gz')
    rows={row['id']:row for row in json.loads(c.decode(saved['run']['stdout_base64']))['rows']}
    selected={key:rows[key] for key in [item['id'] for item in saved['failures']]}
    c.write_new('inspection.json.gz',dict(producer=c.read(c.PREFIX+'inspect.py'),rows=selected,
        scope='Rejected first fixture epoch. Public emitted source identifies copy push syntax, ordinary length lowering and registered sorted admission separately; scalar JSON discrepancy requires internal-kind investigation, not guessed classification.'))
    for name,row in selected.items():
        print(name)
        for line in row['generated']['source'].splitlines():
            if '$items =' in line or 'sub select_items' in line or '$out =' in line or '__ls_take_count' in line:
                print(line[:9000])
    print('loaded',json.loads(c.decode(saved['run']['stdout_base64']))['inc'].get('LinkedSpec/CodeblockRuntime.pm'))

if __name__=='__main__':main()
