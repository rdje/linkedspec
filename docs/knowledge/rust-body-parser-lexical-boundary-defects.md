---
id: rust-body-parser-lexical-boundary-defects
title: Rust compact fluent parsing and header suffixes lose lexical boundaries; Perl and Rust truncate regex braces
answers:
  - why does Rust reject I.return with a space before parentheses
  - why does a quoted closing parenthesis fail in a Rust lifecycle fluent call
  - why does Rust accept an invalid suffix only on a rule header line
  - why does a regex closing brace truncate Perl lifecycle code
  - why does Rust reject a regex closing brace inside a lifecycle block
  - which tasks own compact fluent header suffix and outer regex brace repairs
date: 2026-09-07
status: confirmed bounded defects; repairs pending SESSION-STARTUP-READING.52-.54
tags: [rust, perl, parser, lifecycle, fluent, regex, diagnostics, SESSION-STARTUP-READING]
evidence: "SESSION-STARTUP-READING.3.3.9 reads parser.rs 79–1574 and runs ten paired native body controls, three paired native matches controls, four Perl lowering controls and three direct bootstrap controls. Public values and exact truncated bootstrap payloads distinguish the mechanisms. No implementation or complete-backend signoff is claimed."
reverify: "Run the four repository-managed diagnostic commands below. Their pre-repair results are observations, not green repair acceptance criteria."
---

## Compact calls and header suffixes

Before re-running these diagnostics after a source change, build the current CLI with
`bash tools/run_cargo_local.sh build --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime`.
The recorded September runs used the existing managed build against unchanged source.

Each case uses the same remaining grammar, `/x/ -> Done` followed by `Done: /[a-z]+/`,
with input `xhello`. The successful initialization controls establish that the action executes.

| Top rule initialization | Rust CLI | Perl public Get |
| --- | --- | --- |
| `I.return("ok")` | `"ok"` | `"ok"` |
| `I.return ("ok")` | compile failure | `"ok"` |
| `I.return\t("ok")` (actual tab) | compile failure | `"ok"` |
| `I { return ("ok") }` | `"ok"` | `"ok"` |
| `I.return(")")` | compile failure | `")"` |
| `I { return(")") }` | `")"` | `")"` |
| `I { out = "}"; return("ok") }` | `"ok"` | `"ok"` |
| `I { out = /}/; return("ok") }` | compile failure | null; handler compilation error |
| body-line `I { return("ok") } @unexpected` | compile failure | DSL validation failure |
| header-line `Top:: I { return("ok") } @unexpected` | `"ok"` | DSL validation failure |

Rust failures exit one with compile:error; successful Rust cases exit zero and report
compile:ok/invoke:ok. Perl subprocesses all exit zero; compilation, runtime result and
last_error are checked separately. Successful Perl cases have no exceptions or last_error.
The invalid suffixes report `Unsupported lifecycle block remainder` on both Perl layouts.

Source mechanisms in `rust/linkedspec-core/src/parser.rs`:

- `.52.1`: `parse_fluent_chain_with_remainder` (1313) reads the method name and
  checks for `(` immediately, before horizontal whitespace. It emits an empty call and
  leaves the actual arguments as a suffix. The lifecycle-I raw-suffix validator rejects
  them. The separate completeness scanner already skips whitespace.
- `.52.2`: `extract_paren_content_with_end` (1349) counts every parenthesis
  without quote or regex state. A `)` in the string ends extraction prematurely.
  The braced form reaches the independent expression parser with intact arguments.
- `.53`: `parse_inline_body` (263) breaks on an unrecognized suffix without
  retaining it. `parse_body_elements` (373) retains such a suffix after lifecycle I
  as Raw, and `check_raw_body_elements` in `rust/linkedspec-core/src/validation.rs` (1058) rejects it.
  Header/body equivalence therefore fails before complete compilation. The neighboring
  `advanced && !consumed_line` branch is unreachable after setting consumed_line true;
  `.53` owns reviewing that line-advancement cleanup without inventing a runtime outcome.

These controls do not establish complete fluent, comment, legacy Raw, or other-backend
behavior. `call_spec_handler_subst` independently lowers both quoted-parenthesis and
spaced return forms correctly; their Perl runtime controls also succeed.

```bash
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'BODY_SOURCE_DETAILS'
import subprocess,json
actions=['out = /}/; return("ok")','out = /x/; return("ok")','return(")")','return ("ok")']
for action in actions:
 p=subprocess.run(['perl','-Iperl','-MLinkedSpec','-e','print LinkedSpec::call_spec_handler_subst("Top",$ARGV[0]);',action],capture_output=True,text=True,timeout=30)
 print(json.dumps({'action':action,'exit':p.returncode,'lowered':p.stdout,'stderr':p.stderr}),flush=True)
BODY_SOURCE_DETAILS
```

```bash
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'RUST_BODY_BOUNDARIES'
import subprocess,json
perl_program=r'''use JSON::PP; my $s=$ARGV[0]; my %ctx; my $p=eval { LinkedSpec::Get(\$s,runtime_ctx_ref=>\%ctx) }; my $ce="$@"; my $in="xhello"; my $v; my $ie=""; if(ref($p) eq "CODE") {$v=eval {$p->(\$in)};$ie="$@"} print JSON::PP->new->canonical->allow_nonref->encode({compiled=>ref($p) eq "CODE" ? 1:0,value=>$v,compile_exception=>$ce,invoke_exception=>$ie,last_error=>$ctx{last_error}}),"\n";'''
cases=[
 ('compact_plain','Top::\n I.return("ok")\n'),
 ('compact_space','Top::\n I.return ("ok")\n'),
 ('compact_tab','Top::\n I.return\t("ok")\n'),
 ('braced_space','Top::\n I { return ("ok") }\n'),
 ('compact_quoted_close','Top::\n I.return(")")\n'),
 ('braced_quoted_close','Top::\n I { return(")") }\n'),
 ('braced_quoted_brace','Top::\n I { out = "}"; return("ok") }\n'),
 ('braced_regex_brace','Top::\n I { out = /}/; return("ok") }\n'),
 ('body_invalid_suffix','Top::\n I { return("ok") } @unexpected\n'),
 ('header_invalid_suffix','Top:: I { return("ok") } @unexpected\n'),
]
for name,prefix in cases:
 source=prefix+' /x/ -> Done\nDone:\n /[a-z]+/\n'
 row={'case':name,'source':source}
 for route,args in [('rust',['rust/target/debug/linkedspec-rust','--inline-spec',source,'--input','xhello','--trace','low']),('perl',['perl','-Iperl','-MLinkedSpec','-e',perl_program,source])]:
  try:
   p=subprocess.run(args,capture_output=True,text=True,timeout=30)
   row[route]={'exit':p.returncode,'stdout':p.stdout,'stderr':p.stderr}
  except subprocess.TimeoutExpired as e:
   row[route]={'timeout_seconds':30,'stdout':str(e.stdout),'stderr':str(e.stderr)}
 print(json.dumps(row),flush=True)
RUST_BODY_BOUNDARIES
```

## Outer regex-brace collection

To isolate the accepted regex helper surface from the initial raw regex assignment,
three explicit lifecycle-I `return(matches(...))` cases use the same grammar/input:

| Expression | Rust value/outcome | Perl value/outcome |
| --- | --- | --- |
| `matches("}", "}")` | true | 1 |
| `matches("}", /}/)` | compilation fails, exit one | null; `rule_handler_compile`, `Top`, `_default` |
| `matches("x", /x/)` | true | 1 |

The Perl failure still returns a parser coderef before invocation; subprocess exit zero
does not imply successful handler construction. The controls' true/1 values are recorded
as observed and do not open a separate representation investigation.

Direct `LinkedSpec::BootstrapSpec::run_bootstrap_parse` with the diagnostic secondary
parser suppressed returns `ok=1`, no error, and position 67 for all three sources.
The regex-brace case's ICODE payload is only ` return(matches("}", /`, and its retained
source ends `I { return(matches("}", /}`. Both controls retain their complete payloads.
`perl/LinkedSpec/BootstrapSpec/Core.pm::_build_curly_brace_rule` (1079) provides brace and quoted-string
alternatives without a regex alternative; `_build_non_action_code_block_rule` (734)
stops on that closing-brace token. `.54.1` owns this concrete bootstrap repair.

Rust's `scan_line_for_braces_chars` (1272) similarly tracks quotes and braces but
no regex state. Its collector ends inside `/}/`; `rust/linkedspec-core/src/validation.rs::brace_depth_delta`
(1081) also omits regex state. `.54.2` owns collection and validation together.
The inner expression parser is a separate boundary and cannot restore truncated outer
source. Existing `.9` concerns a different Perl attached-tail scanner; neither owner
is closed by documenting the other.

The attempted parser_source_ref collection in the native matches command produced no
source snippets, so it supplies no emitted-source evidence. The direct bootstrap dump
and inspected scanner owners establish truncation; no generated source execution is claimed.

```bash
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'MATCH_REGEX_BRACES'
import subprocess,json
perl_program=r'''use JSON::PP; my $s=$ARGV[0];my %ctx;my $src="";my $p=eval {LinkedSpec::Get(\$s,runtime_ctx_ref=>\%ctx,parser_source_ref=>\$src)};my $ce="$@";my $in="xhello";my $v;my $ie="";if(ref($p) eq "CODE"){$v=eval{$p->(\$in)};$ie="$@"}my @lines=split /\n/,$src;my @snips;for(my $i=0;$i<@lines;$i++){if($lines[$i]=~/matches|__ls_match|return\s+/){push @snips,{line=>$i+1,text=>$lines[$i]}}}print JSON::PP->new->canonical->allow_nonref->encode({compiled=>ref($p)eq"CODE"?1:0,value=>$v,compile_exception=>$ce,invoke_exception=>$ie,last_error=>$ctx{last_error},source_snippets=>\@snips}),"\n";'''
for expr in ['matches("}", "}")','matches("}", /}/)','matches("x", /x/)']:
 source='Top::\n I { return('+expr+') }\n /x/ -> Done\nDone:\n /[a-z]+/\n'
 row={'expression':expr,'source':source}
 for route,args in [('rust',['rust/target/debug/linkedspec-rust','--inline-spec',source,'--input','xhello','--trace','low']),('perl',['perl','-Iperl','-MLinkedSpec','-e',perl_program,source])]:
  try:
   p=subprocess.run(args,capture_output=True,text=True,timeout=30)
   row[route]={'exit':p.returncode,'stdout':p.stdout,'stderr':p.stderr}
  except subprocess.TimeoutExpired as e:row[route]={'timeout_seconds':30}
 print(json.dumps(row),flush=True)
MATCH_REGEX_BRACES
```

```bash
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'BOOTSTRAP_BRACE_OWNER'
import subprocess,json
program=r'''use JSON::PP; use LinkedSpec::BootstrapSpec; local $LinkedSpec::BootstrapSpec::SPEC_SPEC_BUILDING=1; my $s=$ARGV[0]; my ($ok,$v,$err)=LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$s); print JSON::PP->new->canonical->allow_nonref->encode({ok=>$ok,value=>$v,error=>$err,position=>pos($s)}),"\n";'''
for expr in ['matches("}", "}")','matches("}", /}/)','matches("x", /x/)']:
 source='Top::\n I { return('+expr+') }\n /x/ -> Done\nDone:\n /[a-z]+/\n'
 p=subprocess.run(['perl','-Iperl','-MLinkedSpec','-e',program,source],capture_output=True,text=True,timeout=30)
 print(json.dumps({'expression':expr,'source':source,'exit':p.returncode,'stdout':p.stdout,'stderr':p.stderr}),flush=True)
BOOTSTRAP_BRACE_OWNER
```

Additional validation and Perl scanner reads are diagnostic coverage only, not completion
credit for queued Rust validation reading. `.54.3` owns eventual cross-backend/public
recurrence after the two repairs. No Dart/Julia/Lua outcome is inferred.

Related: [[standalone-lifecycle-block-audit]], [[bootstrap-conditional-regex-delimiters]],
[[rust-header-rest-action-edge-spacing]], [[rust-action-parser-boundary-defects]].
