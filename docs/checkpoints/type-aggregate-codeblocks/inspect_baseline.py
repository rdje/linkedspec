"""Read exact public sources for observed arity and scalar-kind boundaries."""
import json
import common as c


def main():
    rows={row['id']:row for row in json.loads(c.decode(c.load('baseline-run.json.gz')['run']['stdout_base64']))['rows']}
    selected={}
    for name in ('ordinary/sum/receiver-arity','ordinary/min/strings','ordinary/median/strings','deferred/chain'):
        row=rows[name]
        selected[name]=row
        print(name,'native value:',json.dumps(row['native']['value']),
            'cause:',json.dumps(row['native']['runtime_detail']),
            'warnings:',row['generated']['warnings'])
        for line in row['generated']['source'].splitlines():
            if '$items =' in line or '__ls_num_min_source' in line or '__ls_num_median_source' in line:
                print(line[:2300])
    c.write_new('inspection.json.gz',dict(producer=c.read(c.PREFIX+'inspect_baseline.py'),rows=selected,
        baseline=c.identity(c.PREFIX+'baseline-run.json.gz'),
        scope='Public generated source, not inferred implementation. Kind inputs are interpreted through '
              'their exact emitted forms; historical capture-string issue95 remains distinct.'))


if __name__=='__main__':main()
