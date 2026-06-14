# Lispish — recursive nested constructs

Covers: recursive grammar, parentheses matching, nested AST construction.
The canonical recursive-parsing showcase for LinkedSpec.

## How to generate expected.json

Run from the repo root:

```bash
perl -Iperl -MLinkedSpec -MJSON::PP -e '
  open my $fh, "<", "tests/corpus/lispish/input.spec" or die;
  local $/; my $spec = <$fh>; close $fh;
  my $parser = LinkedSpec::Get(\$spec);
  open my $in, "<", "tests/corpus/lispish/input.txt" or die;
  local $/; my $input = <$in>; close $in;
  my $result = $parser->(\$input);
  my $json = JSON::PP->new->pretty->canonical->encode(
    { _meta => { spec_file => "input.spec", description => "Lispish recursive nested constructs", top_rule => "lispish", backend_version => "1.0.0" }, result => $result }
  );
  open my $out, ">", "tests/corpus/lispish/expected.json" or die;
  print $out $json;
  close $out;
'
```
