# TableGrep — action edges, capture groups, LS/LE lifecycle, accumulator

Covers: complex action edges, regex capture groups, LS/LE lifecycle,
accumulator collection, fluent chains.

## How to generate expected.json

Run from the repo root:

```bash
perl -Iperl -MLinkedSpec -MJSON::PP -e '
  open my $fh, "<", "tests/corpus/tablegrep/input.spec" or die;
  local $/; my $spec = <$fh>; close $fh;
  my $parser = LinkedSpec::Get(\$spec);
  open my $in, "<", "tests/corpus/tablegrep/input.txt" or die;
  local $/; my $input = <$in>; close $in;
  my $result = $parser->(\$input);
  my $json = JSON::PP->new->pretty->canonical->encode(
    { _meta => { spec_file => "input.spec", description => "TableGrep action edges, LS/LE, accumulator", top_rule => "tablegrep", backend_version => "1.0.0" }, result => $result }
  );
  open my $out, ">", "tests/corpus/tablegrep/expected.json" or die;
  print $out $json;
  close $out;
'
```
