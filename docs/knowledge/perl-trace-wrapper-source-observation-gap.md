---
id: perl-trace-wrapper-source-observation-gap
title: Generated wrapper source assertion can borrow a later handler's instrumentation
answers:
  - can the non-repetition trace source test miss uninstrumented Top handlers
  - which task repairs the generated trace wrapper source observation
  - does the wrapper trace source diagnosis show a production instrumentation defect
date: 2026-09-22
status: confirmed test observation gap; production instrumentation passes; .2.19 retains required reading prerequisites
tags: [perl, trace, generated-source, tests, conformance]
evidence: "CONFORMANCE-SOURCE-READING.1.89 at dfdb201b6. Four exact-block controls show all six original assertions pass after removing four trace helper references only from the emitted Top body. Bounding assertion4 to Top preserves pristine success and rejects the isolated removal. All source outside Top is restored byte-exact; no production handler is changed or executed after mutation."
reverify: "Run TRACE_WRAPPER_SOURCE_OBSERVATION below through the project-data wrapper. The pinned consumer and exact subtest fail closed after a tracked repair."
---

The final subtest in `t/trace_generated_nonrep_dispatch.t` uses the toolbox's
`LinkedSpec::Get` with `dump_parser_source` and `parser_source_ref`. Its fourth
assertion begins at `Top => sub {` but lets `.*` cross the handler boundary before
matching `trace_generated_handler_branch`. A later `Plus` handler can satisfy it.

The source-extracted control leaves actual compilation and parser construction
unchanged. It isolates Top by its exact emitted indentation, removes only its
four helper-name references in the returned scratch string and verifies that
restoring that single segment recovers the entire original source. The original
six assertions still pass, including Plus instrumentation and max-bound checks.
A bounded version of assertion4 passes pristine production and fails exactly that
assertion after removal; the enclosing subtest then fails as expected.

This demonstrates sensitivity missing from one source assertion. Existing live
non-repetition branch tests remain valid. Current production Top instrumentation
passes the stronger check; no production regression or historical false-green run
is inferred. `CONFORMANCE-SOURCE-READING.2.19` owns the tracked correction after the
required source/book/policy reading, retaining the same positive and rejection proof.

```bash
bash tools/project_data_run.sh env PERL5LIB= python3 - <<'TRACE_WRAPPER_SOURCE_OBSERVATION'
from pathlib import Path
import subprocess,re,json,hashlib
w=Path('.linkedspec-data/scratch/conformance-89');source=Path('t/trace_generated_nonrep_dispatch.t').read_text()
assert hashlib.sha256(source.encode()).hexdigest() == '536ae088d282f7c622caacfd076e06733e41a5a734c70adaa5f8344a979fee46'
prefix=source[:source.index('subtest ')];a=source.index("subtest 'repetition handler bodies");b=source.index('\n};',a)+4;block=source[a:b]
needle=" like($source, qr/Top => sub \\{.*trace_generated_handler_branch/s, 'non-repetition wrapper source is instrumented');"
assert hashlib.sha256(block.encode()).hexdigest() == '3d2bc247d841c847529f7dd6fd236c728481702d121826f5d26ede570d38b146'
assert block.count(needle)==1
boundary=r''' my ($indent, $top_body) = $source =~ /^([ \t]*)Top => sub \{\n(.*?)^\1\},/ms;
 die "cannot isolate exact Top handler\n" unless defined $top_body;
 my $top_count = () = $top_body =~ /trace_generated_handler_branch/g;
 die "original Top has no instrumentation\n" unless $top_count;
 my $before = $source;
 if ($ENV{PROBE_REMOVE_TOP}) {
  my $changed = $top_body;
  $changed =~ s/trace_generated_handler_branch/removed_handler_branch/g;
  my $old = $indent . "Top => sub {\n" . $top_body . $indent . '},';
  my $new = $indent . "Top => sub {\n" . $changed . $indent . '},';
  my $at = index($source, $old); die "missing exact handler\n" if $at < 0;
  substr($source, $at, length($old), $new);
  die "unexpected second handler\n" if index($before, $old, $at+1) >= 0;
  my $restore = $source; substr($restore, $at, length($new), $old);
  die "unrelated source changed\n" unless $restore eq $before;
 }
 my ($after_indent, $observed_top) = $source =~ /^([ \t]*)Top => sub \{\n(.*?)^\1\},/ms;
 die "lost exact Top handler\n" unless defined $observed_top;
 my $observed_count = () = $observed_top =~ /trace_generated_handler_branch/g;
 diag("TOOLBOX dump_parser_source Top original=$top_count observed=$observed_count");
'''
block=block.replace(' ok(defined($parser)',boundary+' ok(defined($parser)',1)
results=[]
for guard in [False,True]:
 for removed in [False,True]:
  variant=('guard' if guard else 'original')+('-removed' if removed else '-pristine')
  probe=block.replace(needle," like($observed_top, qr/trace_generated_handler_branch/, 'non-repetition wrapper source is instrumented');") if guard else block
  path=w/(variant+'.t');path.write_text(prefix+probe+'\nLinkedSpec::Trace::configure_trace(trace_level => "none", trace_log_file => "", trace_log_mode => "stdout");\ndone_testing();\n')
  result=subprocess.run(['bash','tools/project_data_run.sh','env','PERL5LIB=','PROBE_REMOVE_TOP='+str(int(removed)),'perl','-Iperl',str(path)],capture_output=True,text=True)
  output=result.stdout+result.stderr;(w/(variant+'.tap')).write_text(output)
  failures=re.findall(r'^\s*not ok (\d+) - (.*)$',output,re.M)
  expectfail=guard and removed
  assert bool(result.returncode)==expectfail,(variant,output)
  assert len(re.findall(r'^    ok\b',output,re.M))==(5 if expectfail else 6),(variant,output)
  if expectfail:assert failures[0][0]=='4',failures
  results.append(dict(variant=variant,status=result.returncode,failed=failures,toolbox=re.findall(r'TOOLBOX[^\n]+',output)))
print(json.dumps(results,indent=2));(w/'trace-source-proof.json').write_text(json.dumps(dict(source_sha256=hashlib.sha256(source.encode()).hexdigest(),block_sha256=hashlib.sha256(source[a:b].encode()).hexdigest(),results=results),indent=2)+'\n')
TRACE_WRAPPER_SOURCE_OBSERVATION
```

Related: [[trace-generated-nonrep-dispatch]], [[conformance-perl-consumer-reading]].
