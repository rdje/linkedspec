"""Keep the actual first normal; use the observer's exact emitted package names."""
from pathlib import Path

BASE = Path(__file__).resolve().parent
test = Path('t/array_transform_result_guard_composition.t')
text = test.read_text()
old = "    my $package = 'LinkedSpec::ArrayTransformComposition::' . $identifier;"
new = "    (my $public_identifier = $identifier) =~ s/^(?:target_|policy_)//;\n    my $package = 'LinkedSpec::ArrayTransformSelectionProbe::' . $public_identifier;"
assert text.count(old) == 1
test.write_text(text.replace(old, new))
capture = (BASE / 'capture_normal.py').read_text()
capture = capture.replace("'normal_before', 'normal_after'", "'normal_before', 'normal_qualified', 'normal_after'")
capture = capture.replace("('normal_before', 'normal_inverse')", "('normal_before', 'normal_qualified', 'normal_inverse')")
(BASE / 'capture_normal_qualified.py').write_text(capture)
print('Normal qualification keeps exact original public error namespaces; no SDK/profile rewrite')
