---
id: perl-user-function-caller-shadowing
title: "Perl function locals can shadow caller argument expressions"
answers:
  - "why does a user function return null for a same named caller argument"
  - "do Perl user function locals shadow caller argument evaluation"
  - "which task owns Perl user function caller scope repair"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: [startup-reading, perl, actionir, user-functions, scope]
evidence: "SESSION-STARTUP-READING.3.2.25 verifies eight public Get controls and generated source at unchanged baseline baeb984e36a94a15951cd23d4c52def5064cdaca. Scalar, aggregate, and nested caller-name collisions return null; their controls preserve the caller value. All eight descriptors report zero raw dependencies and unresolved helpers. SESSION-STARTUP-READING.32 owns remediation."
reverify: "perl -0777 -ne 'print $1 if /^```bash\\n(.*?)^```/ms' docs/knowledge/perl-user-function-caller-shadowing.md | bash"
---

The intended eager caller-context contract in [[terse-user-function-value-call-execution]] has a measured
Perl exception. A body-local name becomes visible before the generated argument expression evaluates.
Current repair state belongs to `SESSION-STARTUP-READING.32` in `docs/tasks/SESSION-STARTUP-READING.md`.

| Control | Observed result |
| --- | --- |
| Scalar argument `temp`, body-local `temp` | null |
| Literal argument `"outer"` with the same body | `"outer"` |
| Distinct caller name `other` with the same body | `"outer"` |
| Caller name matches only a parameter | `"outer"` |
| Array-valued caller `items`, body-local `items` | null |
| Array-valued distinct caller name | `["outer"]` |
| Nested call whose body-local name matches the outer parameter | null |
| Nested call with a distinct body-local name | `"outer"` |

All eight compile and run without a context error, raw dependency, or unresolved helper. The array-valued
binding uses the uniform scalar slot; its collision also reads null, rather than an empty host array.
Generated scalar source is:

```perl
$temp = "outer"; return do { my $temp; my $__ls_user_fn_arg_0 = $temp;
  my $value = $__ls_user_fn_arg_0; $temp = $value; $temp }
```

`perl/LinkedSpec/ActionIR/MethodLowering.pm:3293` seeds emitted statements with body-local declarations;
3294–3295 then append argument temporary evaluation, before parameter bindings at 3297–3298.
Lowering an argument with caller dependencies does not preserve caller lexical scope when its emitted
expression is placed after a shadowing declaration. The generated nested-call control shows the same
mechanism hiding an outer function parameter.

These are diagnostic observations, not accepted semantics or completed repairs. Other backends, hash/rest
collisions, caller side-effect order, and compiler-temporary name collisions remain for the owning repair's
bounded impact and regression controls. No standalone generated-parser execution is claimed by this dump.

The exact eight-case observation command follows:

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict; use warnings;
my @cases=(
 ['scalar_collision','fn f(value) { temp = value; return(temp) }','temp = "outer"; return(f(temp))',undef],
 ['literal_control','fn f(value) { temp = value; return(temp) }','temp = "outer"; return(f("outer"))','outer'],
 ['distinct_control','fn f(value) { temp = value; return(temp) }','other = "outer"; return(f(other))','outer'],
 ['parameter_control','fn f(value) { return(value) }','value = "outer"; return(f(value))','outer'],
 ['array_collision','fn f(value) { items += "inner"; return(value) }','items = ["outer"]; return(f(items))',undef],
 ['array_distinct','fn f(value) { items += "inner"; return(value) }','other = ["outer"]; return(f(other))',['outer']],
 ['nested_collision','fn outer(value) { return(inner(value)) }'."\n".'fn inner(arg) { value = arg; return(value) }','return(outer("outer"))',undef],
 ['nested_control','fn outer(value) { return(inner(value)) }'."\n".'fn inner(arg) { temp = arg; return(temp) }','return(outer("outer"))','outer']
);
my $json=JSON::PP->new->canonical->allow_nonref;
for my $c(@cases){
 my $spec="$c->[1]\nTop::\n /x/ -> Top { $c->[2] }\n";
 my (%ctx,$source);my $p=LinkedSpec::Get(\$spec,dump_parser_source=>1,parser_source_ref=>\$source,runtime_ctx_ref=>\%ctx);
 die "$c->[0] compile failure" unless ref($p) eq 'CODE';my $input='x';my $got=$p->(\$input);
 print $json->encode({case=>$c->[0],result=>$got,context_error=>defined($ctx{last_error})?1:0}),"\n";
 for my $line(split /\n/,$source//''){print "$line\n" if $line =~ /__ls_user_fn_arg_0/ && $c->[0] =~ /collision/}
 die "$c->[0] context error" if defined($ctx{last_error});
 my $desc=LinkedSpec::Get(\$spec,return_descriptor=>1);
 my $meta=$desc->{spec}{Top}{meta}{action_rewriter};
 print $json->encode({case=>$c->[0],raw_perl_dependency_count=>$meta->{raw_perl_dependency_count}//0,unresolved_helper_count=>$meta->{unresolved_helper_count}//0}),"\n";
}
PERL
```
