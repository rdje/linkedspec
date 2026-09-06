---
id: perl-semantic-inline-header-lifecycle-loss
title: "Perl semantic source scanning drops explicit lifecycle blocks placed after a rule header"
answers:
  - "why is an inline I lifecycle block absent from Perl semantic introspection"
  - "does moving an I block to the next line change semantic lifecycle records"
  - "which task fixes semantic rule-header tail loss"
date: 2026-09-06
status: confirmed-open
tags: [perl, semantic-introspection, lifecycle, source-scanning, startup-reading]
evidence: "SESSION-STARTUP-READING.3.2.42 preserves forward .3.2.44 diagnostic evidence: four public Get/query controls and two outward descriptor controls at unchanged baseline baeb984e. SemanticStaticProjection.pm 483–493/568–611/676–700 directly explains the omitted member."
reverify: "Run the managed public matrix below; compare explicit I forms separately from the bare-block controls."
---

An explicit `I` block on the same physical line as its rule header executes successfully but is absent
from the public semantic query. Moving that same block onto the following line preserves execution and
adds the expected lifecycle record.

| Authored form | Public parser result | Explicit lifecycle records |
| --- | --- | --- |
| `Top:: I { return(7) }` | 7 | none |
| `Top::`, then `I { return(7) }` on the next line | 7 | `lifecycle:rule:Top:I:0` |
| Header-inline bare `{ return(7) }` | 7 | none |
| Following-line bare `{ return(7) }` | 7 | none |

All four Get contexts remain error-free and all four public list queries succeed. The multiline I record
has marker I, number value shape, and source bytes 7–22 for the exact fixture. The bare controls do not
establish that a synthetic explicit I marker should be invented.

Two additional descriptor-return controls have identical outward metadata: default or/seek family,
no action or blind edges, and no regex slots. Their entries contain dependency_refs, handler, and meta;
they do not expose lifecycle body fields. The evidence therefore does not claim that outward descriptors
themselves contain an omitted lifecycle record. See [[outward-descriptor-is-not-semantic-wire-model]].

`_parse_header` returns a tail, but `_scan_source` records the entire trimmed header line and immediately
continues to the next line. It never feeds that tail into member capture. Lifecycle construction then
uses only captured members, so the inline I block cannot appear. The public rule source span also covers
the whole inline line (0–21) instead of the multiline header's 0–5; exact intended header/member span
boundaries belong to the repair audit.

The existing static projection suite deep-compares five fixture groups/controls, including the
missing-dependency failure and clone/privacy boundaries. Its five top-level tests pass in the preceding
canonical run. Those fixtures do not prove this inline/multiline equivalence.

[[SESSION-STARTUP-READING]] `.43` owns precise member/source-span authority, supported inline-form and
six-runtime census, bounded repair decomposition, independent regressions, and book/Knowledge/recurrence
closure. Other runtimes were not measured here. The separate empty-function call gate remains `.22`,
and the fabricated failure explanation remains `.23`. No runtime or public-book repair is claimed.

## Reverify

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;
LinkedSpec::configure_trace(level=>'none');
my $json=JSON::PP->new->canonical;
for my $case (
 ['inline_I',"Top:: I { return(7) }\n"],
 ['multiline_I',"Top::\n I { return(7) }\n"],
 ['inline_bare',"Top:: { return(7) }\n"],
 ['multiline_bare',"Top::\n { return(7) }\n"],
) {
 my($name,$source)=@$case;my %context;
 my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
 die "$name construction" unless ref($parser) eq 'CODE' && !$context{last_error};
 my $input='x';my $value=$parser->(\$input);
 die "$name invocation" if $context{last_error};
 my $index=LinkedSpec::semantic_index(\$source,logical_name=>'inline-control.spec',source_detail_ceiling=>'text');
 my $response=$index->query({
  contract=>'linkedspec-semantic-query-v1',operation=>'list',subjects=>[],record_kinds=>[],relation_kinds=>[],direction=>'outgoing',
  page=>{after_id=>undef,limit=>100},budget=>{max_records=>1000,max_relations=>2000,max_depth=>4},
  source=>{detail=>'span',include_content_digest=>JSON::PP::false},
 });
 die "$name query" unless $response->{ok};
 my @records=map {{id=>$_->{id},kind=>$_->{kind},facts=>$_->{facts},source=>$_->{source}}}
  grep {$_->{kind} eq 'rule'||$_->{kind}=~/lifecycle/} @{$response->{records}};
 print $json->encode({case=>$name,result=>$value,context_error=>$context{last_error},records=>\@records}),"\n";
}
PERL
```
