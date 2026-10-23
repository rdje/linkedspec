"""Record the existing scalar consumer at the unchanged runtime boundary."""
import common as c
import context


def main():
    supplied = context.snapshot()
    c.write_new('focused-inputs.json.gz',supplied)
    run = c.run(['bash','tools/project_data_run.sh','prove','-Iperl','t/scalar_numeric_contract.t'])
    stable = c.unchanged(supplied['inputs'])
    c.write_new('focused.json.gz',dict(run=run,inputs_unchanged=stable,
        producer=c.read(c.PREFIX+'focused.py'),scope='Existing scalar numeric and permanent count/first native/generated consumer; no runtime source change.'))
    assert stable and run['returncode']==0 and not c.decode(run['stderr_base64'])
    print('Core scalar numeric consumer PASS; runtime inputs unchanged')


if __name__ == '__main__':
    main()
