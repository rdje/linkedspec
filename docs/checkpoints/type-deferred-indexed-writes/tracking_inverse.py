"""Restore the old assignment result in actual source, observe RED, restore GREEN."""
import common as c
import compare_tracking
comparison=compare_tracking.check()
assert comparison==c.load('tracking-full-row-comparison.json.gz')['result']
path=c.SOURCES[1]
original=c.read(path)
source=c.decode(original['base64']).decode()
old=r''' return 'do { $'.$target.' = '.$value_expr.'; $__ls_binding_presence{"'.$target.'"} = 1; scalar($'.$target.') }' '''.rstrip()
new=r''' my $tail = $returns_value ? '; $'.$target : '';
 return 'do { $'.$target.' = '.$value_expr.'; $__ls_binding_presence{"'.$target.'"} = 1'.$tail.' }' '''.rstrip()
assert source.count(old)==1
suites=['t/actionir_tracking_predicate_capture.t','t/callable_codeblock_literal_contract.t']
command=['bash','tools/project_data_run.sh','prove','-q','-Iperl']+suites
context=c.epoch()
try:
 (c.ROOT/path).write_text(source.replace(old,new,1))
 fault=c.read(path)
 syntax=c.run(['bash','tools/project_data_run.sh','perl','-Iperl','-c',path])
 assert syntax['returncode']==0
 red=c.run(command)
finally:(c.ROOT/path).write_bytes(c.decode(original['base64']))
green=c.run(command)
restored=c.read(path)==original
c.save('tracking-assignment-inverse.json.gz',dict(path=path,context=context,original=original,fault=fault,
 syntax=syntax,red=red,green=green,restored=restored,suites={p:c.read(p) for p in suites},
 comparison=comparison,producer=c.read(c.PREFIX+'tracking_inverse.py')))
assert restored and red['returncode']!=0 and green['returncode']==0
stderr=c.decode(red['stderr_base64'])
assert b'preserves complete native row with private authority' in stderr
assert b'tracked scalar assignments preserve values and remain quiet in every context' in stderr
print('Actual syntax-valid old-result inverse rejects both consumer/source and executable value oracles; exact restoration GREEN')
