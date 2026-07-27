---
id: lua-outward-function-descriptor-union
title: Lua emits the exact shared fixed-v1 variadic-v2 and final-codeblock-v3 descriptor union
answers:
  - does Lua emit outward user function descriptors
  - what descriptor version does Lua use for variadic functions
  - what descriptor version does Lua use for final codeblock functions
  - where is the exact outward function descriptor union defined
  - does Lua preserve signature metadata in outward descriptors
  - does Lua preserve parameter kinds in outward descriptors
  - why does Perl final codeblock descriptor use version 3
date: 2026-07-15
status: current
tags: [lua, perl, descriptors, callable-signature, codeblock, parameter-kinds, staged-parsing, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.3.1 extends outward_descriptor_contract.json with the checked three-variant union, makes Lua emit all variants, and aligns Perl's existing final-codeblock outward version. PUC Lua and LuaJIT pass 153/153; focused Perl callable tests pass 76."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_signature_contract.py && bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && PERL5LIB= prove -Iperl t/variadic_user_function_contract.t t/callable_codeblock_literal_contract.t && bash tools/run_lua_local.sh"
---

`capability_conformance/outward_descriptor_contract.json:function_record_variants` is the executable source of
truth for outward user-function records:

- `fixed_v1` stores exact `params` and `arity`;
- `variadic_v2` stores the exact callable `signature` instead;
- `final_codeblock_v3` stores fixed `params` and `arity` plus exact `parameter_kinds`.

The version-3 `parameter_kinds` object has exactly one entry. Its key is the final parameter name and its value is
`codeblock`; version 3 never carries `signature`. `tools/check_callable_signature_contract.py` rejects top-level,
variant-set, field-order, version, parameter-storage, compatibility-alias, or final-codeblock-policy drift.

Lua's `user_function_registry.to_descriptor_json(...)` selects the outward variant from typed registry state. A
callable signature selects v2; otherwise final-only parameter-kind metadata selects v3; an ordinary fixed
definition selects v1. All variants share the same source/provenance/body fields. Signature or parameter-kind
values are projected from the same immutable definition that owns `body_payload` and `body_parse_job`, and focused
tests require byte-equivalent JSON copies across those records. Compiled descriptor metadata preserves source
`function_order`, zero-based record indices, and exact `function_count` on both PUC Lua and LuaJIT.

Perl already exposed the complete final-codeblock field set before this contract existed, but labeled that outward
record v1. `.5.3.1` changes only the outward projection to v3; its internal version-1 fixed definition, staged
records, and runtime behavior do not change. Rust, Dart, and Julia continue to emit the variants their current
function features support. The v3 descriptor does not admit generic explicit callable-codeblock values or change
the capability census.

Related facts: [[lua-descriptor-trace-admission-split]], [[lua-final-codeblock-metadata]],
[[lua-variadic-v2-signature-state]], [[outward-function-descriptor-record-shape-drift]].
