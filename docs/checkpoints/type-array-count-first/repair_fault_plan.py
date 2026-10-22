"""Retain an ambiguous fault-marker refusal and scope it to the new helper block."""
import common as c
import context


def main():
    path = c.PREFIX+'faults.py'
    original = c.read(path)
    supplied = context.snapshot()
    run = c.run(['bash','tools/run_python_project_data.sh',path])
    c.write_new('fault-plan-refusal.json.gz',dict(producer=original,context=supplied,run=run))
    assert run['returncode'] == 1 and b'AssertionError: receiver-arity' in c.decode(run['stderr_base64'])
    text = c.decode(original['base64']).decode()
    old = "'   return undef if @$args || $index < $#$calls;'"
    prefix = '  if ($method eq \'count\' || $method eq \'first\') {\n'
    replacements = {
        old:repr(prefix+'   return undef if @$args || $index < $#$calls;'),
        "'   return undef if $index < $#$calls;'":repr(prefix+'   return undef if $index < $#$calls;'),
        "'   return undef if @$args;'":repr(prefix+'   return undef if @$args;'),
    }
    for before,after in replacements.items():
        assert before in text
        text = text.replace(before,after)
    c.source(path).write_text(text)
    c.source(path).chmod(original['mode'])
    c.write_new('fault-plan-repair.json.gz',dict(before=original,after=c.read(path),
        scope='Preflight rejected a marker shared with aggregate terminal guards before any source fault. Prefix the exact newly added count/first block; source runtime is unchanged.'))
    print('Fault marker now uniquely selects the count/first preflight')


if __name__ == '__main__':
    main()
