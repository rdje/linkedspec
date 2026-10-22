"""Apply the bounded compiler/preflight repair after preserving actual RED."""
import common as c

def main():
    emitter,runtime=c.SOURCES
    replacements=[(emitter,
        "   my $aggregate_args = $call->{args} || [];\n   if ($method =~ /\\A(?:sum|avg|median|range)\\z/) {",
        "   my $aggregate_args = $call->{args} || [];\n   return 'undef' if $method eq 'sorted' && @$aggregate_args;\n   return 'undef' if $method eq 'take' && @$aggregate_args > 1;\n   return 'undef' if $method eq 'length' && (@$aggregate_args || $index < $#$calls);\n   if ($method =~ /\\A(?:sum|avg|median|range)\\z/) {"),
      (emitter,
        "   return undef unless _is_array_receiver_value_chain_method($method);\n   my $arg_exprs = $chain_arg_exprs->($call->{args} || []);",
        "   return undef unless $method eq 'length' || _is_array_receiver_value_chain_method($method);\n   my $arg_exprs = $chain_arg_exprs->($call->{args} || []);"),
      (emitter,
        "  my $current_expr = $receiver_expr;\n  $current_expr = 'array('.$current_expr.')'\n   if ($receiver->{kind} // '') eq 'variable'",
        "  my $current_expr = $receiver_expr;\n  # Keep function-owned names in DSL form until the aggregate lowerer reads\n  # their scalar-backed typed value; reparsing $name loses that binding.\n  $current_expr = $receiver->{name}\n   if ($receiver->{kind} // '') eq 'variable'\n   && _user_function_scalar_value_name($deps, $receiver->{name});\n  $current_expr = 'array('.$current_expr.')'\n   if ($receiver->{kind} // '') eq 'variable'"),
      (runtime,
        "  if ($method eq 'count' || $method eq 'first') {\n   return undef if @$args || $index < $#$calls;",
        "  if ($method eq 'count' || $method eq 'first' || $method eq 'length') {\n   return undef if @$args || $index < $#$calls;")]
    before={path:c.read(path) for path in c.SOURCES}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    for path,old,new in replacements:
        assert after[path].count(old)==1,(path,old)
        after[path]=after[path].replace(old,new,1)
    c.write_new('implementation-before.json.gz',dict(sources=before,replacements=replacements,
        context=c.epoch(),producer=c.read(c.PREFIX+'implement.py')))
    for path,text in after.items():
        c.source(path).write_text(text)
    c.write_new('implementation.json.gz',dict(before=before,after={p:c.read(p) for p in c.SOURCES},replacements=replacements))
    print('Applied four exact bounded lowering/preflight hunks')

if __name__=='__main__':main()
