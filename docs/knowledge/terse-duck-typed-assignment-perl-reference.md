---
id: terse-duck-typed-assignment-perl-reference
title: "SPEC-FORMAT-TERSE.11.2 - Perl bare assignment binds typed values in one scalar value slot."
answers:
  - "does Perl name = [value] still infer an array working variable"
  - "how does Perl set(name, {}) lower after duck typed assignment"
  - "does return(set(items, [value])) yield a scalar held array value"
  - "how do array(name) and hash(name) read scalar held typed values"
  - "does generated Perl still emit my @name for name = []"
  - "what remains for Rust duck typed assignment parity"
date: 2026-07-05
status: current
tags: [spec-format-terse, assignment, duck-typing, variables, perl, actionir, value-binding, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.11.2 changed the Perl reference lowering in perl/LinkedSpec/ActionIR/MethodLowering.pm and declaration collection in perl/LinkedSpec/RuleIR/EmitContext.pm. Bare assignment targets now bind the evaluated RHS value through one scalar value slot: `name = []` -> `$name = []`, `name = { key => value }` -> `$name = {$key => $value}`, `set(name, [value])` -> `$name = [$value]`, and expression-valued `set` / `=` forms return `$name`. The collector records `my $name` for those bare targets and no longer records `my @name` or `my %name` solely because the RHS is a direct shape. Explicit aggregate mutation targets remain aggregate storage: `set(array(items), [value])` still lowers through `@items`, and `set(hash(meta), {...})` still lowers through `%meta`. `array(name)` and `hash(name)` read scalar-held typed values through guarded snapshots when type memory says `name` is scalar-bound. Rust still has the old direct-shape target-retagging behavior until SPEC-FORMAT-TERSE.11.3 lands."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{name = []}, q{name = { key => value }}, q{set(name, [value])}, q{return(set(items, [value]))}, q{return(=(items, [value]))}, q{return(set(array(items), [value]))}) { my $out = LinkedSpec::call_spec_handler_subst(\"Top\", $stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }'"
---

# Perl Duck-Typed Assignment Reference

Perl bare assignment targets now bind typed RHS values through one scalar value slot:

```text
name = [value]              # $name = [$value]
name = { key => value }     # $name = {$key => $value}
set(name, [value])          # $name = [$value]
```

Expression-valued assignment returns the scalar-held typed value:

```text
return(set(items, [value])) # return do { $items = [$value]; $items }
return(=(items, [value]))   # return do { $items = [$value]; $items }
```

Generated Perl should declare `my $items` / `my $meta` for those bare shape assignments, not `my @items` or
`my %meta` solely from RHS shape.

Explicit aggregate mutation targets remain deliberate aggregate storage:

```text
set(array(items), [value])        # @items = (...)
set(hash(meta), { key => value }) # %meta = (...)
```

When type memory says a name is scalar-bound, `array(name)` and `hash(name)` read the scalar-held typed value through
guarded array/hash snapshots. Rust parity is pending in `SPEC-FORMAT-TERSE.11.3`.
