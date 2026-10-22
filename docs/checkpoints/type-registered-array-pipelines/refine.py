"""Preserve rejected candidate1 and repair its synthetic-expression boundary."""
import common as c

def main():
    path=c.SOURCES[0]
    before=c.read(path)
    text=c.decode(before['base64']).decode()
    replacements=[(
        "  # Numeric shape errors are complete null expressions, including mixed chains.\n  # They must not reach the legacy Perl fallback or execute a receiver first.",
        "  # Invalid call shapes and terminal continuations are complete null\n  # expressions; reject them before lowering any receiver or operand effects."),(
        "  $current_expr = 'array('.$current_expr.')'\n   if ($receiver->{kind} // '') eq 'variable'\n   && $current_expr =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;",
        "  $current_expr = 'array('.$current_expr.')'\n   if ($receiver->{kind} // '') eq 'variable'\n   && !_user_function_scalar_value_name($deps, $receiver->{name})\n   && $current_expr =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;"),(
        "   return $lower_synthetic_chain_expr->($current_expr)\n  }\n\n  return undef\n };\n\n $lower_ast_receiver_mutation_chain_node",
        "   # This composition can already contain emitted callback expressions.\n   # Consume it through the existing compatibility bridge without parsing\n   # host temporaries as new DSL expressions.\n   return $legacy_method_value_expr->($current_expr)\n  }\n\n  return undef\n };\n\n $lower_ast_receiver_mutation_chain_node")]
    for old,new in replacements:
        assert text.count(old)==1,old
        text=text.replace(old,new,1)
    c.write_new('refinement-before.json.gz',dict(source=before,replacements=replacements,context=c.epoch(),
        producer=c.read(c.PREFIX+'refine.py'),explanation='Actual candidate1 sources yield nested parameter arrays and unsupported take on computed callback expressions. No expectations change. Preserve spec-level function names without constructor wrapping; consume the existing synthetic host/DSL composition through the existing compatibility bridge.'))
    c.source(path).write_text(text)
    c.write_new('refinement.json.gz',dict(before=before,after=c.read(path),replacements=replacements))
    print('Refined exact array-chain bridge; original candidate1 remains immutable')

if __name__=='__main__':main()
