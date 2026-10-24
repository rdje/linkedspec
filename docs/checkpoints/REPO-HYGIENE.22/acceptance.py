"""Retain actual final reader channels once, before sealing the publication."""
import common as c


def main():
    runs = [c.run(['bash', 'tools/run_python_project_data.sh', c.PREFIX + name])
        for name in ('review.py', 'check_artifact_epoch.py')]
    c.write_new('acceptance.json.gz', dict(producer=c.read(c.PREFIX + 'acceptance.py'), runs=runs))
    assert all(run['returncode'] == 0 and not c.decode(run['stderr_base64']) for run in runs)
    print('Final retained readers PASS; actual complete channels saved.')


if __name__ == '__main__':
    main()
