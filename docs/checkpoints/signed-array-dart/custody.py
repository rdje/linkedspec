"""One-shot final custody including actual publication-input fault observations."""
import common as c

controls=c.load('input-controls.json.gz');assert controls['inputs_restored']
names=sorted(path.name for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file())
assert 'custody.json' not in names
c.save('custody.json',dict(version=1,inputs={name:c.identity(c.PREFIX+name) for name in names},
    scope='Complete final dated namespace, including immutable base manifest and actual '
        'input-control packets. The final claim binds this custody record separately. '
        'No self reference, source refresh, runtime rerun or future mutable-book binding.'))
print('Final custody inputs:',len(names))
