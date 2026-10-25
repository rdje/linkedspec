"""One-shot capture manifest; never rerun after acceptance."""
import common as c

names=sorted(path.name for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file())
assert 'publication.json' not in names
c.save('publication.json',dict(version=1,inputs={name:c.identity(c.PREFIX+name) for name in names},
    scope='Closed dated Dart source/fixture/actual executable/channel and producer inputs. '
        'Subsequent physical input-control observations have separate final custody. '
        'Actual before sources match clean activation contents and Git executable class; full '
        'filesystem permissions are retained/guarded separately. Installed SDK/locked hosted '
        'packages/OS/mdBook/Python and original accepted Git objects are read-only prerequisites.'))
print('Closed publication inputs:',len(names))
