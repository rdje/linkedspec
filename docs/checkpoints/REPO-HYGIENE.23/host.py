"""Permitted host process/cwd and volume evidence; never authorize from EPERM."""
import datetime
import os
import sys
import common as c


def main(label):
    assert label in ('host-before','host-after','host-final')
    inputs=c.snapshot(['tools/project_data_env.sh','tools/project_data_run.sh',
        'docs/knowledge/project-data-liveness-permission-denial.md'])
    c.save(label+'-inputs.json.gz',inputs)
    runs={
        'processes':c.run(['ps','-axo','pid,ppid,pgid,uid,stat,etime,comm']),
        'cwd':c.run(['lsof','-nP','-a','-u',str(os.getuid()),'-d','cwd','-Fpcn']),
        'volume':c.run(['df','-k','.']),
        'git_objects':c.run(['git','count-objects','-v']),
        'worktrees':c.run(['git','worktree','list','--porcelain']),
    }
    c.save(label+'.json.gz',dict(at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
        uid=os.getuid(),runs=runs,inputs_unchanged=c.unchanged(inputs['inputs']),
        scope='Actual permitted host process table, current-user process cwd metadata and volume/Git '
            'allocation APIs. This necessary read-only OS inspection may name external cwd paths; '
            'it reads no other repository payloads and writes only owned evidence. Candidate-specific '
            'open-file inspection and immediate rechecks are separately required before removal. '
            'Nonzero/denied/unknown inspection never establishes absence. No recovery or purge command.'))
    assert all(row['returncode']==0 and not c.decode(row['stderr_base64']) for row in runs.values()),{
        name:(row['returncode'],c.decode(row['stderr_base64']).decode()) for name,row in runs.items()}
    print('Host observation retained:',label,'; no removal authorized by this record alone.')


if __name__=='__main__':
    assert len(sys.argv)==2
    main(sys.argv[1])
