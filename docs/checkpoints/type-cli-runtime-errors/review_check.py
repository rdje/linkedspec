"""Retain the actual first source/data reader invocation and its inputs."""
import common as c
import context


def main():
    epoch = context.snapshot()
    reader = c.read(c.PREFIX+'review.py')
    run = c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'review.py'])
    stable = c.unchanged(epoch['inputs'])
    c.write_new('review-check.json.gz',dict(context=epoch,reader=reader,run=run,
        producer=c.read(c.PREFIX+'review_check.py'),inputs_unchanged=stable))
    assert stable
    print(c.decode(run['stdout_base64']).decode(),end='')
    print(c.decode(run['stderr_base64']).decode(),end='')
    assert run['returncode']==0, 'source/data reader preflight'


if __name__ == '__main__':
    main()
