"""Apply only the count/first interpreter contract and free-call kind guards."""
import common as c
import context


def main():
    assert c.load('accepted-run.json.gz')['inputs_unchanged']
    supplied = context.snapshot()
    c.write_new('implementation-inputs.json.gz', supplied)
    runtime, emitter = c.SOURCES[:2]
    edits = [
        (runtime, " if ($name eq 'sorted' || $name eq 'take') {", """ if ($name eq 'count' || $name eq 'first') {
  return undef unless @$args == 1;
  my $value = _eval_expr($args->[0], $ctx);
  return _array_selection($name, $value)
 }

 if ($name eq 'sorted' || $name eq 'take') {"""),
        (runtime, 'sub _numeric_receiver_helper_name {', """# Both call spellings use the stored element unchanged, including false/null
# and callable values. Invocation/container boundaries retain their own copying.
sub _array_selection {
 my ($name, $value) = @_;
 return ref($value) eq 'ARRAY' ? scalar(@$value) : 0 if $name eq 'count';
 return ref($value) eq 'ARRAY' && @$value ? $value->[0] : undef
}

sub _numeric_receiver_helper_name {"""),
        (runtime, "  return undef if $method eq 'take' && @$args > 1;", """  return undef if $method eq 'take' && @$args > 1;
  if ($method eq 'count' || $method eq 'first') {
   return undef if @$args || $index < $#$calls;
  }"""),
        (runtime, "  if ($method eq 'sorted') {", """  if ($method eq 'count' || $method eq 'first') {
   $value = _array_selection($method, $value);
   next;
  }
  if ($method eq 'sorted') {"""),
        (emitter, "defined($__ls_count) ? scalar(@{$__ls_count}) : 0",
            "ref($__ls_count) eq \\'ARRAY\\' ? scalar(@{$__ls_count}) : 0"),
        (emitter, "defined($__ls_first) && @{$__ls_first} ? $__ls_first->[0] : undef",
            "ref($__ls_first) eq \\'ARRAY\\' && @{$__ls_first} ? $__ls_first->[0] : undef"),
    ]
    before = {path:c.read(path) for path in (runtime, emitter)}
    replacements = []
    for path, old, new in edits:
        text = c.source(path).read_text()
        assert text.count(old) == 1, (path,old,text.count(old))
        c.source(path).write_text(text.replace(old,new,1))
        c.source(path).chmod(before[path]['mode'])
        replacements.append(dict(path=path, old=old, new=new))
    c.write_new('implementation.json.gz', dict(before=before,
        after={path:c.read(path) for path in before}, replacements=replacements))
    print('Applied count/first dispatch, terminal preflight and two ARRAY guards')


if __name__ == '__main__':
    main()
