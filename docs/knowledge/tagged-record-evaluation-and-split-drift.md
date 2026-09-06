---
id: tagged-record-evaluation-and-split-drift
title: "Perl and PUC Lua tagged records disagree on field evaluation and empty items"
answers:
  - "why does Perl split_tagged_records evaluate a field more than once"
  - "why do tagged records drop trailing empty items on Perl"
  - "which task owns tagged record evaluation and split parity"
  - "do Perl and Lua split agree on an empty source"
date: 2026-09-06
status: dated diagnostic evidence; contract review and repair are task-owned
tags: [startup-reading, perl, lua, tagged-records, split, parity]
evidence: "SESSION-STARTUP-READING.3.2.28 compares public Perl Get and the PUC Lua primary CLI for a,b, and empty sources. Perl evaluates the carried increment per emitted row and uses split without a trailing-empty limit. PUC Lua evaluates arguments once and reuses pure split. SESSION-STARTUP-READING.33.1 owns authority/impact review; .33.2 owns the reviewed repair."
reverify: "perl -0777 -ne 'print $1 if /^```bash\\n(.*?)^```/ms' docs/knowledge/tagged-record-evaluation-and-split-drift.md | bash"
---

The helper reference at `docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md:1163`
teaches once-only source/tag/carried-field evaluation. The measured Perl implementation conflicts with that
claim; the PUC Lua control follows it. This is not authority to silently change the reference or oracle.
`SESSION-STARTUP-READING.33` owns reconciliation and the resulting implementation work.

Each probe starts `counter` at zero, builds tagged rows with carried field `set(counter, add(counter, 1))`,
and returns `[records, counter, split(source, ",")]`:

| Source | Perl Get | PUC Lua primary CLI |
| --- | --- | --- |
| `"a,b,"` | `[[["row","a",1],["row","b",2]],2,["a","b",""]]` | `[[["row","a",1],["row","b",1],["row","",1]],1,["a","b",""]]` |
| `""` | `[[],0,[]]` | `[[["row","",1]],1,[""]]` |

Both Perl controls have no context error; both PUC commands exit 0. In addition to tagged-row trailing-item
drift, the empty-source controls expose an ordinary pure-split difference. Other backends, LuaJIT, generated
execution, regex/variable delimiters, tag effects, and carried aggregate independence remain unmeasured here.

`perl/LinkedSpec/ActionIR/MethodLowering.pm:6068`–6075 puts carried expressions inside the generated
`map` body and emits Perl `split` without the `-1` used by ordinary split. The dumped handler therefore
increments once per produced item, and not at all when no item exists.
`lua/src/linkedspec/interpreter.lua:1926`–1940 materializes arguments before helper execution;
1897–1907 reuses pure split and copies the materialized fields into each record. Its literal splitter
at 1093–1106 always appends the remaining suffix, including the empty-source suffix.

Perl observation command:

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;
for my $input_source ('a,b,','') {
 my $spec='Top::'."\n".' /x/ -> Top { counter = 0; source = "'.$input_source.'"; records = split_tagged_records(source, ",", "row", set(counter, add(counter, 1))); return([records,counter,split(source,",")]) }'."\n";
 my (%ctx,$src);my $p=LinkedSpec::Get(\$spec,runtime_ctx_ref=>\%ctx,dump_parser_source=>1,parser_source_ref=>\$src);
 die 'compile' unless ref($p) eq 'CODE';my $input='x';my $got=$p->(\$input);
 print JSON::PP->new->canonical->encode({source=>$input_source,result=>$got,context_error=>defined($ctx{last_error})?1:0}),"\n";
 for my $line(split /\n/,$src){print "$line\n" if $line =~ /\[map \{/}
 die 'context error' if defined($ctx{last_error});
}
PERL
```

Fresh PUC Lua controls (same authored specs and input):

```bash
bash tools/run_lua_project_data.sh puc lua/bin/linkedspec-lua --inline-spec 'Top::
 /x/ -> Top { counter = 0; source = "a,b,"; records = split_tagged_records(source, ",", "row", set(counter, add(counter, 1))); return([records,counter,split(source,",")]) }
' --input x
bash tools/run_lua_project_data.sh puc lua/bin/linkedspec-lua --inline-spec 'Top::
 /x/ -> Top { counter = 0; source = ""; records = split_tagged_records(source, ",", "row", set(counter, add(counter, 1))); return([records,counter,split(source,",")]) }
' --input x
```

Related: [[lua-runtime-tagged-record-construction]], [[lua-pure-split-bridge]],
[[terse-source-migration-runtime-boundaries]].
