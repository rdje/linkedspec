---
id: and-bare-nonnumeric-selector-loss
title: Rust and Perl discard named or malformed selectors on AND bare edges
answers:
  - "why does an AND bare Child named selector act like plain Child"
  - "does Rust reject a malformed selector on an AND bare edge"
  - "does Perl retain named selector provenance on a bare blind call"
  - "why does Child zero reject while Child missing compiles in AND"
  - "which task owns nonnumeric bare selector loss"
date: 2026-09-07
status: confirmed defect; SESSION-STARTUP-READING.57 owns repair
tags: [rust, perl, selectors, bare-edges, cursor, validation, descriptor, defect]
evidence: "SESSION-STARTUP-READING.3.3.12 at activation 75ce8db839888a5091d25ee4e5e1c3c501daf3b8; five paired native controls and four Perl public descriptor projections; Rust parser/validation/compiler; perl/LinkedSpec/RuleIR.pm blind bare normalization; ADR 0044 and inter_match_gap_capture_contract.json."
reverify: "Run the two exact managed probes below; build the Rust primary CLI first with bash tools/run_cargo_local.sh build --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --bin linkedspec-rust."
---

The parent is `Top::AND`; the child declares named slot `word = /xhello/`.
ADR 0044 assigns bare AND edges blind ownership, with parent-owned slot selection
requiring explicit action syntax. Current named-slot authority distinguishes
unindexed, numeric and named selectors. Malformed `[!]` is not a valid slot name.

| Bare source | Rust compile/result | Perl compile/result |
| --- | --- | --- |
| `Child` | Accepted; `["selected"]` | Accepted; null |
| `Child[0]` | Rejected, CLI exit 1 | Rejected, `bare_edge_index_requires_action` |
| `Child[word]` | Accepted; `["selected"]` | Accepted; null |
| `Child[missing]` | Accepted; `["selected"]` | Accepted; null |
| `Child[!]` | Accepted; `["selected"]` | Accepted; null |

Every accepted Rust case reports compile/invoke success. All Perl subprocesses
exit zero; numeric rejection retains `normalize_edges` and the existing target /
`regex_index=0` fields. No subprocess times out. Perl's plain control also returns
null, so these runs establish acceptance, not a new isolated Perl return-path
failure. Existing `.27` remains its separate investigation.

Four independent public `return_descriptor` probes compare plain, named, unknown
and malformed cases. All produce the identical Top metadata: `family=and`,
`cursor_policy=consume`, `edge_ownership=blind`, one blind Child row with null
`regex_index` and empty `resolved_slot_edges`. Selector provenance is lost before
the public projection.

Rust's `parse_bare_target_list_prefix` retains the typed selector but sets legacy
`index` only for `Numeric`. Slot validation skips AND bare targets; edge-structure
validation then checks only `index.is_some()`. The compiler replaces the selected
target with an unindexed dependency at zero and a blind child/code entry.

Perl RuleIR similarly guards blind bare targets with `defined(index)`, then emits
`bcode_entries` with child/code and normalized rows containing label/index/fluent.
Named-selector fields survive only the action branch. The complete authored
selector must be checked before this lossy normalization.

`SESSION-STARTUP-READING.57.1` owns exact portable diagnostics and complete selector
authority; `.57.2` and `.57.3` own Rust and Perl fixes; `.57.4` owns remaining
backend/carrier verification and public closeout. Explicit blind/action twins,
empty/unclosed selectors, generated execution and other backends remain unmeasured.
Passing cursor/gap fixtures and 21 core validation tests do not close these cases.

Native comparison:

```bash
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'SLICE71_AND_SELECTOR'
import subprocess,json
perl_program=r'''use JSON::PP;my $s=$ARGV[0];my %ctx;my $p=eval{LinkedSpec::Get(\$s,runtime_ctx_ref=>\%ctx)};my $ce="$@";my $in="xhello";my $v;my $ie="";if(ref($p)eq"CODE"){$v=eval{$p->(\$in)};$ie="$@"}print JSON::PP->new->canonical->allow_nonref->encode({compiled=>ref($p)eq"CODE"?1:0,value=>$v,compile_exception=>$ce,invoke_exception=>$ie,last_error=>$ctx{last_error}}),"\n";'''
for edge in ['Child','Child[0]','Child[word]','Child[missing]','Child[!]']:
 source='Top::AND\n '+edge+'\nChild:\n word = /xhello/\n E { return("selected") }\n'
 row={'edge':edge,'source':source}
 for route,args in [('rust',['rust/target/debug/linkedspec-rust','--inline-spec',source,'--input','xhello','--trace','low']),('perl',['perl','-Iperl','-MLinkedSpec','-e',perl_program,source])]:
  try:
   p=subprocess.run(args,capture_output=True,text=True,timeout=30)
   row[route]={'exit':p.returncode,'stdout':p.stdout,'stderr':p.stderr}
  except subprocess.TimeoutExpired:row[route]={'timeout_seconds':30}
 print(json.dumps(row),flush=True)
SLICE71_AND_SELECTOR
```

Independent Perl descriptor projection:

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'SLICE71_DESCRIPTOR'
use strict;
use warnings;
for my $edge ('Child','Child[word]','Child[missing]','Child[!]') {
 my $source="Top::AND\n $edge\nChild:\n word = /xhello/\n E { return(\"selected\") }\n";
 my %ctx;
 my $d=LinkedSpec::Get(\$source,return_descriptor=>1,runtime_ctx_ref=>\%ctx);
 my $meta=ref($d) eq 'HASH' ? $d->{spec}{Top}{meta} : undef;
 print JSON::PP->new->canonical->encode({
  edge=>$edge,compiled=>ref($d) eq 'HASH'?1:0,
  meta=>defined($meta)?{map { $_=>$meta->{$_} } qw(family cursor_policy edge_ownership resolved_edges resolved_slot_edges)}:undef,
  last_error=>$ctx{last_error}
 }),"\n";
}
SLICE71_DESCRIPTOR
```

Related: [[rust-rule-local-cursor-normalization]], [[rule-local-cursor-and-bare-edge-contract]],
[[inter-match-gap-rust-implementation-plan]], [[rust-body-parser-lexical-boundary-defects]].
