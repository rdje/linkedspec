---
id: terse-duck-typed-assignment-perl-reference
title: "SPEC-FORMAT-TERSE.11.2 - Perl bare assignment binds typed values in one scalar value slot."
answers:
  - "does Perl name = [value] still infer an array working variable"
  - "how does Perl set(name, {}) lower after duck typed assignment"
  - "does return(set(items, [value])) yield a scalar held array value"
  - "how do array(name) and hash(name) read scalar held typed values"
  - "does Perl copy(items) read a scalar held array value after items = [value]"
  - "does Perl copy(items) auto declare my @items after items = [value]"
  - "do Perl bare array receiver chains read scalar held arrays after duck typed assignment"
  - "does generated Perl still emit my @name for name = []"
  - "where is Rust duck typed assignment parity recorded"
date: 2026-07-05
status: current
tags: [spec-format-terse, assignment, duck-typing, variables, perl, actionir, value-binding, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.11.2 changed the Perl reference lowering in perl/LinkedSpec/ActionIR/MethodLowering.pm and declaration collection in perl/LinkedSpec/RuleIR/EmitContext.pm. Bare assignment targets now bind the evaluated RHS value through one scalar value slot: `name = []` -> `$name = []`, `name = { key => value }` -> `$name = {$key => $value}`, `set(name, [value])` -> `$name = [$value]`, and expression-valued `set` / `=` forms return `$name`. The collector records `my $name` for those bare targets and no longer records `my @name` or `my %name` solely because the RHS is a direct shape. Explicit aggregate mutation targets remain aggregate storage: `set(array(items), [value])` still lowers through `@items`, and `set(hash(meta), {...})` still lowers through `%meta`. `array(name)` and `hash(name)` read scalar-held typed values through guarded snapshots when type memory says `name` is scalar-bound. SPEC-FORMAT-TERSE.11.3 then closed the oracle-exposed Perl readback gap by making scalar-held `copy(name)` and bare array receiver chains consult the remembered scalar-held array/hash value before aggregate-storage fallback. RuleIR::EmitContext also follows remembered scalar kind for `copy(name)`, so generated source keeps `my $items` / `my $meta` and does not add `my @items`, `my @meta`, or `my %meta` for scalar-held readback. SPEC-FORMAT-TERSE.11.3 also landed Rust parity; see [[terse-rust-duck-typed-assignment-parity]]."
reverify: "perl -Iperl -MJSON::PP -MLinkedSpec -e 'my $spec = qq{Top::\\n /x/ -> Done { set(value, \"ok\"); set(key, \"stage\"); items = [value]; meta = { key => value }; return(array(:items, array(items), copy(items), items.count(), items.first(), :meta, hash(meta), copy(meta), meta.count_keys(), meta.pick_keys(key).sorted_values().first())) }\\n\\nDone::\\n /[a-z]+/\\n}; my $p = LinkedSpec::Get(\\$spec); my $in = \"xhello\"; print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\$in)), \"\\n\";'"
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
guarded array/hash snapshots. `copy(name)` and bare array receiver chains such as `items.count()` / `items.first()`
also read that scalar-held value before falling back to aggregate storage. Generated source should keep scalar
preambles for these scalar-held readbacks. Rust parity landed in [[terse-rust-duck-typed-assignment-parity]].
