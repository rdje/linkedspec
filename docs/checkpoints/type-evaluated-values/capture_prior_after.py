"""Retain a fresh whole original reader replay after current runtime/documentation edits."""
import common as c
import replay_inventory

c.write_new(c.PREFIX + 'prior-after-inputs.json', dict(producer=c.read(c.PREFIX + 'capture_prior_after.py'),
    reader=c.read(c.PREFIX + 'replay_inventory.py'), helper=c.read(c.PREFIX + 'common.py'),
    scope='The reader supplies the whole original388 target and nested accepted context; current '
          'main runtime and documentation edits remain present. Original sources/channels stay exact.'))
result = replay_inventory.replay()
c.write_new(c.PREFIX + 'prior-after-run.json', result)
print('Whole original inventory reader still replays after current runtime/documentation edits')
