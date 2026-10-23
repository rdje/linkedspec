"""Reject missing typed operand headers before earlier write operands can run."""
import json
import common as c
command=['bash','tools/project_data_run.sh','perl','-Iperl',c.PREFIX+'operand_probe.pl']
original=c.read(c.SOURCES[0]);before=c.run(command)
text=c.decode(original['base64']).decode()
needle='sub _write_span {'
assert text.count(needle)==1
text=text.replace(needle,'''sub _write_operand_is_typed {
 my ($node) = @_;
 return ref($node) eq 'HASH' && defined($node->{kind})
  && !ref($node->{kind}) && length($node->{kind}) ? 1 : 0
}

'''+needle,1)
old="&& ref($segments) eq 'ARRAY' && @$segments && ref($node->{value}) eq 'HASH';"
assert text.count(old)==1
text=text.replace(old,"&& ref($segments) eq 'ARRAY' && @$segments && _write_operand_is_typed($node->{value});",1)
old="&& ref($segment->{expression}) eq 'HASH';"
assert text.count(old)==1
text=text.replace(old,'&& _write_operand_is_typed($segment->{expression});',1)
c.save('operand-validation-before.json.gz',dict(source=original,run=before,producer=c.read(c.PREFIX+'repair_operand.py'),probe=c.read(c.PREFIX+'operand_probe.pl')))
(c.ROOT/c.SOURCES[0]).write_text(text)
after=c.run(command)
c.save('operand-validation.json.gz',dict(source=c.read(c.SOURCES[0]),run=after,producer=c.read(c.PREFIX+'repair_operand.py'),probe=c.read(c.PREFIX+'operand_probe.pl')))
assert before['returncode']==after['returncode']==0
old=json.loads(c.decode(before['stdout_base64']));new=json.loads(c.decode(after['stdout_base64']))
assert all(row['seen'] and row['code']=='unsupported_codeblock_actionir' for row in old)
assert all(row['seen']=='' and row['code']=='invalid_codeblock_body' and row['document']=={} for row in new)
print('Malformed operand headers: actual earlier-effect RED / no-effect typed GREEN')
