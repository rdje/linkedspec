"""Apply bounded aggregate runtime dispatch and complete invalid receiver shapes."""
import common as c


def main():
    paths=['perl/LinkedSpec/Numeric.pm',c.SOURCE,'perl/LinkedSpec/ActionIR/MethodLowering.pm']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    numeric=paths[0]
    old='sub arity_is_valid {'
    addition='''# Array reducers retain the existing Perl aggregate policy, independently of
# CONTRACT_ID: every term must match the legacy decimal spelling. In particular,
# this does not add scalar-number finite/boolean rules or normalize selected
# original min/max/odd-median terms (the separate result-kind repair owns those).
sub array_helper_name {
 my ($name) = @_;
 return undef unless defined($name) && !ref($name);
 my $helper = $name =~ /\\Anum_/ ? $name : 'num_'.$name;
 return $helper if $helper =~ /\\Anum_(?:sum|avg|median|range|min|max)\\z/;
 return undef
}

sub evaluate_array {
 my ($helper, $source) = @_;
 $helper = array_helper_name($helper);
 return undef unless defined($helper) && ref($source) eq 'ARRAY';
 foreach my $term (@$source) {
  return undef unless defined($term) && $term =~ /\\A-?(?:\\d+(?:\\.\\d+)?|\\.\\d+)\\z/;
 }
 if ($helper eq 'num_sum' || $helper eq 'num_avg') {
  my $total = 0;
  $total += $_ for @$source;
  return $total if $helper eq 'num_sum';
  return @$source ? $total / @$source : undef
 }
 return undef unless @$source;
 if ($helper eq 'num_median') {
  my @terms = sort { $a <=> $b } @$source;
  my $middle = int(@terms / 2);
  return @terms % 2 ? $terms[$middle] : ($terms[$middle - 1] + $terms[$middle]) / 2
 }
 my ($minimum, $maximum) = ($source->[0], $source->[0]);
 foreach my $term (@$source) {
  $minimum = $term if $term < $minimum;
  $maximum = $term if $term > $maximum;
 }
 return $minimum if $helper eq 'num_min';
 return $maximum if $helper eq 'num_max';
 return $maximum - $minimum
}

'''
    assert after[numeric].count(old)==1
    after[numeric]=after[numeric].replace(old,addition+old,1)
    runtime=c.SOURCE
    old=' my $numeric = LinkedSpec::Numeric::scalar_helper_name($name);'
    new=''' my $aggregate = LinkedSpec::Numeric::array_helper_name($name);
 if (defined($aggregate) && ($aggregate !~ /\\Anum_(?:min|max)\\z/ || @$args == 1)) {
  return undef unless @$args == 1;
  return LinkedSpec::Numeric::evaluate_array($aggregate, _eval_expr($args->[0], $ctx))
 }

'''+old
    assert after[runtime].count(old)==1
    after[runtime]=after[runtime].replace(old,new,1)
    old="  # Array reducers remain a separately owned interpreter family.\n  _error('unknown_helper', name => $name) if $array_overload && ref($numbers[0]) eq 'ARRAY';\n"
    assert after[runtime].count(old)==1
    after[runtime]=after[runtime].replace(old,'',1)
    old="  my $helper = $numeric[$index];\n  next unless defined($helper);"
    new='''  my $method = $calls->[$index]{method} // '';
  my $args = $calls->[$index]{args} || [];
  if ($method =~ /\\A(?:sum|avg|median|range)\\z/) {
   return undef if @$args || $index < $#$calls;
  }
  return undef if ($method eq 'min' || $method eq 'max') && !@$args && $index < $#$calls;
  my $helper = $numeric[$index];
  next unless defined($helper);'''
    assert after[runtime].count(old)==1
    after[runtime]=after[runtime].replace(old,new,1)
    old="  my $numeric = _numeric_receiver_helper_name($method);\n  if (defined($numeric)) {"
    new='''  my $aggregate = $method =~ /\\A[a-z]+\\z/ ? LinkedSpec::Numeric::array_helper_name($method) : undef;
  if (defined($aggregate) && ($method !~ /\\A(?:min|max)\\z/ || ref($value) eq 'ARRAY')) {
   return undef if @{$call->{args} || []};
   $value = LinkedSpec::Numeric::evaluate_array($aggregate, $value);
   next;
  }
  my $numeric = _numeric_receiver_helper_name($method);
  if (defined($numeric)) {'''
    assert after[runtime].count(old)==1
    after[runtime]=after[runtime].replace(old,new,1)
    old="   _error('unknown_helper', name => $method) if $array_overload && ref($value) eq 'ARRAY';\n"
    assert after[runtime].count(old)==1
    after[runtime]=after[runtime].replace(old,'',1)
    compiler=paths[2]
    old="   my $family = _number_receiver_value_chain_return_family($method);\n   next unless defined($family);"
    new='''   my $aggregate_args = $call->{args} || [];
   if ($method =~ /\\A(?:sum|avg|median|range)\\z/) {
    return 'undef' if @$aggregate_args || $index < $#$calls;
   }
   return 'undef' if ($method eq 'min' || $method eq 'max') && !@$aggregate_args && $index < $#$calls;
   my $family = _number_receiver_value_chain_return_family($method);
   next unless defined($family);'''
    assert after[compiler].count(old)==1
    after[compiler]=after[compiler].replace(old,new,1)
    old="   if ($method =~ /^(?:sum|avg|median|range|min|max)$/o) {\n    return undef unless @$arg_exprs == 0;"
    new="   if ($method =~ /^(?:sum|avg|median|range|min|max)$/o) {\n    return ['undef', 'terminal'] unless @$arg_exprs == 0;"
    assert after[compiler].count(old)==1
    after[compiler]=after[compiler].replace(old,new,1)
    c.write_new('implementation.json.gz',dict(before=before,after={path:c.encode(raw.encode()) for path,raw in after.items()},
        producer=c.read(c.PREFIX+'implementation.py'),scope='Three bounded owners; no ordinary aggregate '
        'algorithm or scalar contract changes. Complete invalid shapes precede receiver/operand effects.'))
    for path,raw in after.items():(c.ROOT/path).write_text(raw)
    print('Applied aggregate runtime dispatch and invalid receiver shape guards')


if __name__=='__main__':main()
