---
id: bootstrap-conditional-regex-delimiters
title: Bootstrap attached conditional tails truncate regex-literal closing delimiters
answers:
  - why does a regex brace in an attached else block fail on Perl
  - why is bootstrap conditional slash-quote recognition unreachable
  - where is attached conditional regex truncation tracked for repair
date: 2026-09-06
status: confirmed defect; repair pending SESSION-STARTUP-READING.9
tags: [perl, bootstrap, regex, control-flow, diagnostics]
evidence: "SESSION-STARTUP-READING.3.2.4 reads baseline BootstrapSpec/Core.pm and probes its attached-tail owner: quoted-brace control consumes 20/20 characters, regex-brace tail consumes only 16/20, and escaped-parenthesis regex condition only 25/44. Public parser with quoted matches pattern returns 1; regex /}/ returns undef with rule_handler_compile Search pattern not terminated."
reverify: "bash tools/project_data_run.sh perl -Iperl -MLinkedSpec::BootstrapSpec::Core -MJSON::PP -e 'for my $s (q~else { return(\"}\") }~,q~else { return(/}/) }~) { my ($tail,$end)=LinkedSpec::BootstrapSpec::Core::_parse_optional_attached_if_clause_tail(\\$s,0); print JSON::PP->new->canonical->encode({source=>$s,tail=>$tail,end=>$end,length=>length($s)}),qq{\\n}; }'"
---

The attached-tail balanced scanner in `perl/LinkedSpec/BootstrapSpec/Core.pm` receives the opening `(` or `{`
position at lines 333–343. Its slash branch takes the prefix beginning at that opening delimiter (lines 292–295),
trims only trailing whitespace, and requires the prefix to be empty before entering slash-quote mode. That
condition cannot hold for a slash inside the balanced region: the opening delimiter remains in the prefix.
Consequently regex `}` or `)` participates in structural depth at lines 302–309 and can end the tail early.

Direct owner controls:

- `else { return("}") }` preserves the complete 20-character tail.
- `else { return(/}/) }` stops at character 16, inside the regex.
- `elseif(matches(")", /\)/)) { return("yes") }` stops at 25 of 44 characters, inside the condition.

`LinkedSpec::call_spec_handler_subst` independently lowers `return(matches("}", /}/))` into a valid regex match
expression. The complete public control is:

```text
Top::
 /x/ -> Done.if(false) { return(false) } else { return(matches("}", /}/)) }

Done::
 /x/
```

Both that source and its quoted-pattern `"}"` twin produce descriptors and parser coderefs. Executing the twin
on `x` returns `1`. Executing the regex form returns undef and records `rule_handler_compile`, rule `Top`,
handler variant `_default`, with `Search pattern not terminated` at generated handler line 58. The private
scanner controls establish the truncation; the public run establishes user-visible impact. No source was changed.

Repair `.9` follows required reading and `.7`/`.8`. It must preserve the existing division-symbol distinction,
lexical escapes and quoted text, source positions, nested tails, and all three caller forms. Broader regex/brace
behavior outside this attached-tail owner was not verified by this diagnostic slice.

Related: [[spec-arithmetic-call-surface-ground-truth]], [[bootstrapspec-vs-spec-spec-dual-path]].
