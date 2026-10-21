"""Retain rejected214 classification; correct scaffold/policy and scalar-overload effects."""
import json
import common as c


def main():
    paths=[c.SOURCE,'perl/LinkedSpec/Numeric.pm',c.PREFIX+'oracle.py']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    runtime=c.SOURCE
    old="  if (defined($aggregate) && ($method !~ /\\A(?:min|max)\\z/ || ref($value) eq 'ARRAY')) {"
    new="  if (defined($aggregate) && ($method !~ /\\A(?:min|max)\\z/ || !@{$call->{args} || []})) {"
    assert after[runtime].count(old)==1
    after[runtime]=after[runtime].replace(old,new,1)
    old="  my $array_overload = ($numeric eq 'num_min' || $numeric eq 'num_max') && @$args == 1;\n  return undef unless $array_overload || LinkedSpec::Numeric::arity_is_valid($numeric, scalar(@$args));"
    new="  return undef unless LinkedSpec::Numeric::arity_is_valid($numeric, scalar(@$args));"
    assert after[runtime].count(old)==1
    after[runtime]=after[runtime].replace(old,new,1)
    numeric=paths[1]
    old=''' my ($minimum, $maximum) = ($source->[0], $source->[0]);
 foreach my $term (@$source) {
  $minimum = $term if $term < $minimum;
  $maximum = $term if $term > $maximum;
 }
 return $minimum if $helper eq 'num_min';
 return $maximum if $helper eq 'num_max';
 return $maximum - $minimum'''
    new=''' if ($helper eq 'num_min' || $helper eq 'num_max') {
  my $selected;
  foreach my $term (@$source) {
   $selected = $term if !defined($selected)
    || ($helper eq 'num_min' ? $term < $selected : $term > $selected);
  }
  return $selected
 }
 my ($minimum, $maximum, $seen);
 foreach my $term (@$source) {
  if ($seen) {
   $minimum = $term if $term < $minimum;
   $maximum = $term if $term > $maximum;
  } else {
   ($minimum, $maximum, $seen) = ($term, $term, 1);
  }
 }
 return $maximum - $minimum'''
    assert after[numeric].count(old)==1
    after[numeric]=after[numeric].replace(old,new,1)
    oracle=paths[2]
    old="        else:\n            native=row['native'];generated=row['generated']"
    new='''        elif 'source_error' in case:
            native=row['native'];generated=row['generated']
            detail=native['runtime_detail'];envelope=generated['exception']
            if not (native['completed'] and native['value'] is None and detail is not None
                and case['source_error'] in detail.get('text','') and not generated['completed']
                and envelope is not None and envelope.get('fields',{}).get('code')=='generated_execution_failed'
                and case['source_error'] in str(envelope['fields'].get('detail',''))
                and not native['warnings'] and not generated['warnings']):reasons.append('source-name-rejection')
        else:
            native=row['native'];generated=row['generated']'''
    assert after[oracle].count(old)==1
    after[oracle]=after[oracle].replace(old,new,1)
    rows=[]
    values={'sum':12,'avg':4,'median':3,'range':7,'min':1,'max':8}
    for source in c.load('final-cases.json')['cases']:
        row=dict(source)
        parts=row['id'].split('/')
        if parts[-1]=='strings':row['expected']=values[parts[1]]
        if parts[-1]=='receiver-arity' and parts[1] in ('min','max'):row['expected']=[None,'x']
        if parts[-1]=='captures':
            row['source']='Top::\n -> Value .push\n LX { return(copy(Top)) }\n\nValue: '+row['pattern']+'\n I { '+row['body']+' }\n'
            row['expected']=[values[parts[1]]]
        if row['id']=='deferred/registered-name':
            row.pop('expected')
            row['source_error']="User function 'sum' collides with built-in helper/control name 'sum'"
        rows.append(row)
    c.write_new('cases2.json',dict(cases=rows,scope='214 fixed values/diagnostics after retained rejected '
        'preparation: public entry scaffold, canonical JSON versus internal kinds95, forbidden built-in '
        'function name, and valid scalar-overload eager effects. No95 fix or arbitrary pipeline admission.'))
    c.write_new('refinement.json.gz',dict(before=before,after={path:c.encode(raw.encode()) for path,raw in after.items()},
        rejected_review=c.read(c.PREFIX+'candidate1-review.json.gz'),
        previous_fixture=c.read(c.PREFIX+'final-cases.json'),producer=c.read(c.PREFIX+'refine_candidate.py'),
        scope='Actual candidate18 mismatches remain retained. Twelve were an invalid capture scaffold; '
              'three assumed historical JSON tags; two assigned the wrong scalar-overload effects; one '
              'used a forbidden built-in function name. Runtime min/max with explicit arguments evaluates '
              'scalar operands before kind rejection. Array helper comparisons follow only selected family. '
              'Internal selected-string defect95 is independently reproduced by real nested writes.'))
    for path,raw in after.items():(c.ROOT/path).write_text(raw)
    print('Refined aggregate candidate; original214 and actual18 discrepancies retained')


if __name__=='__main__':main()
