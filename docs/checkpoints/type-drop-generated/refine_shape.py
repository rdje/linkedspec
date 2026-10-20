"""Retain the first candidate and close its raw hash-key shape fallthrough."""
import common as c


def main():
    before = c.read(c.SOURCE)
    old = (b'   my $key_lowered = $lower_flat_list_value_expr->($key_expr);\n'
           b'   $key_lowered = $lower_scalar_access_key_expr->($key_expr)\n')
    new = (b'   my $key_lowered = $lower_flat_list_value_expr->($key_expr);\n'
           b'   $key_lowered = $lower_shape_literal_value_expr->($key_expr)\n'
           b'    unless defined($key_lowered) && length($key_lowered);\n'
           b'   $key_lowered = $lower_scalar_access_key_expr->($key_expr)\n')
    raw = c.decode(before['base64'])
    assert raw.count(old) == 1
    after = raw.replace(old, new, 1)
    c.write_new('shape-refinement.json.gz', dict(before=before, after_base64=c.encode(after),
        producer=c.read(c.PREFIX+'refine_shape.py'),
        observation='All34 desired values and quiet profiles pass in green1, but two hash-valued '
                    'diagnostic keys still emit raw DSL colon shapes. The first adjacent-brace '
                    'hypothesis was incomplete; the exact tool-dumped source retains the actual '
                    'unlowered shape. Lower that shape through the existing typed shape producer. '
                    'No portable reference-key coercion contract follows.'))
    (c.ROOT/c.SOURCE).write_bytes(after)
    print('Retained green1; lower hash-key shapes before scalar access fallback')


if __name__ == '__main__':
    main()
