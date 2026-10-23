"""Keep dynamic presence attached to weak resolved-slot identity across forwarded calls."""
import common as c
path=c.SOURCES[0]
original=c.read(path)
assert original==c.load('forwarded-presence.json.gz')['sources'][path]
text=c.decode(original['base64']).decode()
def replace(old,new):
 global text
 assert text.count(old)==1,(old,text.count(old))
 text=text.replace(old,new,1)
replace('fieldhash my %codeblock_origins;', '''fieldhash my %codeblock_origins;
# A forwarded callable can introduce a working slot unknown to its compiled
# caller. Its presence must survive the next invocation through that same slot.
# Weak keys follow the slot lifetime without capturing a callable environment.
fieldhash my %binding_presence_by_slot;''')
replace(' return $binding if _is_scalar_binding_ref($binding);', ''' if (_is_scalar_binding_ref($binding)) {
  my $present = $ctx->{presence}{$name};
  if (_is_scalar_binding_ref($present)) {
   $binding_presence_by_slot{$binding} = $present;
  } elsif (exists $binding_presence_by_slot{$binding}) {
   $ctx->{presence}{$name} = $binding_presence_by_slot{$binding};
  }
  return $binding;
 }''')
replace(' $ctx->{presence}{$name} = \\$present;', ''' $ctx->{presence}{$name} = \\$present;
 $binding_presence_by_slot{$ctx->{bindings}{$name}} = \\$present;''')
replace(' $ctx->{presence}{$name} = \\$value;', ''' $ctx->{presence}{$name} = \\$value;
 my $binding = $ctx->{bindings}{$name};
 $binding_presence_by_slot{$binding} = \\$value if _is_scalar_binding_ref($binding);''')
c.save('presence-repair.json.gz',dict(before=original,after=text,producer=c.read(c.PREFIX+'repair_presence.py')))
(c.ROOT/path).write_text(text)
print('Presence lifetime repaired by weak resolved-slot identity')
