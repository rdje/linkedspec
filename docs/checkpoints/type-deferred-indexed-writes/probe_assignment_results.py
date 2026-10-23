import json
import common as c
run=c.run(['bash','tools/project_data_run.sh','perl','-Iperl',c.PREFIX+'probe_assignment_results.pl'])
c.save('assignment-result-context-before.json.gz',dict(run=run,
 sources={path:c.read(path) for path in c.SOURCES},producer=c.read(c.PREFIX+'probe_assignment_results.pl'),
 controller=c.read(c.PREFIX+'probe_assignment_results.py')))
assert run['returncode']==0,run
for row in json.loads(c.decode(run['stdout_base64']))['rows']:
 print(row['name'],row['context'],'warnings',len(row['warnings']),'error',row['error'],
  json.dumps(row['values'],sort_keys=True))
