---
id: lua-contract-parser-reading-and-string-boundary-gap
title: Lua contract and parser reading locates incomplete quoted-literal acceptance
answers:
  - what did Lua startup reading group three cover
  - why does Lua accept adjacent quoted literals as one string
  - does Lua reject an escaped final quote without a closing delimiter
  - which task fixes Lua complete string literal boundaries
  - how can Lua parser diagnostics run without building native modules
  - what is the measured Lua current helper inventory in September
  - how does Lua distinguish contextual and inert callable contract traversal
date: 2026-09-12
status: exact group three read; quoted-literal repair pending
tags: [lua, parser, actionir, contracts, strings, reading, diagnostics]
evidence: "LUA-STARTUP-READING.1.3 reads 1500 fragments /50,175 bytes from clean cbb483fb4633e1cd246002f105cb81ecacb92a19; source baseline remains exact. Pure ActionIR/contract probes pass 32 valid controls on measured PUC 5.5.1 and LuaJIT 2.1.1788460057, and identify three direct plus three nested malformed-string acceptances on each. .2.5/.2.5.1/.2.5.2 own complete literal parsing and independent verification."
reverify:
  - "Run the self-contained pure-module recipe below from the repository root; record lua -v and luajit -v through tools/project_data_run.sh."
  - "Use the LUA_READING_COVERAGE recipe in docs/knowledge/lua-startup-reading-coverage.md to recheck all 99 source files and every exact group/range."
  - "perl tools/check_language_capability_coverage.pl --report"
  - "bash tools/run_python_project_data.sh tools/check_callable_signature_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_punctuation_light_zero_arg_contract.py"
---

# Exact reading and scope

Activation: `cbb483fb4633e1cd246002f105cb81ecacb92a19`; source baseline:
`baeb984e36a94a15951cd23d4c52def5064cdaca`. Nine untruncated physical windows
cover call names 240–317; contracts 1–175, 176–350, 351–525, 526–700;
parser 1–180, 181–360, 361–540, 541–722. No parser suffix reading is claimed.

| Path | Inclusive LF lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| `lua/src/linkedspec/action_call_names.lua` | 240–317 | 1961 | `bf361c8cfa1efd0333fdc20a2f4ed8498d35c87f24ddaaa50bfcf8aad4573238` |
| `lua/src/linkedspec/action_contracts.lua` | 1–700 | 25197 | `b4187bb6d1381a25789afc6e4b6642137cd1e5d05d3838d7882e28cc4d0b9c66` |
| `lua/src/linkedspec/action_parser.lua` | 1–722 | 23017 | `3a317a771ee0807b0f412da9d9ac427d0fbcdec9558833e49656d1e2a0a25e48` |

Ordered range SHA-256 is
`ba94240ececbe936a8f99a4bdc0651f87cf7aaad1e2eb9a348fa6a2e98166f40`:
1,500 fragments /50,175 bytes. Cumulative reading is 3/51 groups,
3,945 fragments /170,028 bytes, nine complete files and one partial parser.
Hashes verify ownership; they do not replace the physical reading above.

# Comprehension and canonical reconciliation

The call-name suffix keeps seven source-boundary compatibility spellings outside
the current shared set, while retaining an explicit seven-name complete-mark view.
The public list/map accessors return defensive copies and the list is sorted.
Fresh pure-module measurement is 250 current names; the independent coverage checker
also reports 250 names, 105 corpus fixtures plus one exact mark fixture and 126
public Perl contracts without omissions. The older 239/246 counts in
[[lua-actionir-contract-resolver]] and [[lua-runtime-helper-no-drift-closeout]]
are dated implementation measurements, not the current inventory. Preserve them.

The contract resolver canonicalizes numeric/control/compatibility names and records
families, surfaces, positional/keyword counts and authored source spans. Ordinary
user-function registry resolution precedes helper fallback; known user functions
reject keyword calls and report explicit arity mismatch. Recursive traversal covers
assignments, containers, access expressions, controls and receiver continuations.
Dedicated recognition/staged/progressive nodes are outside the ordinary helper set.
Unknown helper and raw fallback nodes produce diagnostics instead of host-global
execution. This resolution is structural classification, not runtime admission.

Final-codeblock metadata is narrowly contextual. Only one fixed final codeblock
parameter, or an admitted built-in final slot, can promote a structural block to a
typed contextual argument. Normalization copies the call and argument list, leaving
a harray unchanged. Explicit callable literals stay inert during contract traversal;
contextual blocks are visited. Canonical owners [[lua-final-codeblock-metadata]]
and [[lua-callable-codeblock-literal-state]] already define these distinctions.

The parser prefix separates slash-symbol calls from regex literals, tracks quote,
escape, regex and delimiter depth, splits only top-level separators and attached
branches, and recognizes assignment equals independently of comparison operators.
Strict UTF-8 validation constructs byte-boundary-to-Unicode-scalar coordinates before
building spans. Callable signatures enforce identifier, reserved-name, uniqueness and
final-rest constraints, retaining body spans in the same root coordinate system.
The read access prefix distinguishes literal string keys from evaluated indexes and
begins typed reserved-root/unclosed-segment diagnostics; its remainder belongs to .1.4.
[[lua-actionir-ast-parser]] remains the full parser API owner.

# Confirmed complete-string boundary defect

`action_parser.lua` lines 538–543 recognize a string solely by matching its first
and last delimiter, then unescape the whole interior. They do not check whether an
unescaped matching delimiter already ended the literal or whether the final quote
is itself escaped. The public parser emits a valid string and contract resolution
reports `ok=true` for both malformed classes:

- Adjacent `"a" "b"` becomes the value `a" "b`; the single-quote twin becomes `a' 'b`.
- The six-byte source consisting of opening quote, `abc`, backslash and quote has
  no unescaped terminator, but becomes the value `abc` plus a trailing backslash.
- `cat("a" "b")`, `['a' 'b']` and `value = "a" "b"` likewise receive successful
  resolution with the malformed interior retained as one string.

This violates complete one-literal recognition; no implicit string concatenation is
admitted. The formal grammar's primitive literals and
[[single-quoted-action-strings-variant-contract]] supply the existing language boundary.
Valid escaped-quote, opposite-quote, regex-escape and Unicode controls all pass.
Lua .2.5.1 owns escape-aware full-literal recognition and exact direct/nested tests;
.2.5.2 independently verifies supported compiled/reconstructed/generated routes.
All source repairs remain behind startup prerequisites and declared-primary .2.2 proof.
No other backend's behavior or full Lua runtime result is inferred from these probes.

A separate regex observation is expected: `/[/]/` is rejected, while `/[\/]/` is
accepted. The public regex chapter explicitly requires escaping the slash delimiter
inside a pattern. This creates no new character-class defect or syntax proposal.

# Focused executable proof

The pure parser, AST, contracts, JSON and inventory modules load through their own
public Lua module APIs under the managed generic process wrapper documented in
TOOLBOX.md section 4.4.2. No native adapter is built or loaded. Exact runtime census
reports PUC 5.5.1 and LuaJIT 2.1.1788460057; pkg-config reports matching installed
versions. [[lua-native-readme-and-action-ast-reading]] owns the unversioned-primary
drift. These observations establish no declared PUC 5.4.8 conformance.

Each measured runtime passes 32 positive/boundary controls: defensive inventory,
compatibility canonicalization, symbolic aliases, recursive unknown-call diagnostics,
contextual versus inert traversal, fixed callback metadata, signatures, all three
physical newline forms, punctuation-light context, Unicode spans, escaped regex
and string syntax and strict UTF-8. Separately, six malformed-string cases per runtime
confirm the pending defect; they are not counted as correct conformance behavior.
The shared signature checker passes 3 definitions/9 calls/7 invalid definitions;
callable checker passes 7/11/9/7/4/8 cases and 23 governance mutations; punctuation
passes 6 standalone/4 receiver/6 invalid forms. No full component/CI gate is claimed.

# Self-contained pure-module replay

This dated probe expects the observed defect, so its malformed observations should
change after .2.5.1; use that repair's regression proof at that point.

```lua
package.path = "lua/src/?.lua;lua/src/?/init.lua;" .. package.path
local p = require("linkedspec.action_parser")
local a = require("linkedspec.action_ast")
local c = require("linkedspec.action_contracts")
local j = require("linkedspec.json")
local names = require("linkedspec.action_call_names")
local checks = 0
local function check(value, label)
  assert(value, label)
  checks = checks + 1
end
local function parse(source) return p.parse_action_expression(source) end
local function resolve(source) return c.resolve_action_expression_contracts(parse(source)) end
print("RUNTIME", _VERSION, jit and jit.version or "PUC")
local current = names.current_names()
check(names.count() == 250 and #current == 250, "exact admitted inventory")
local sorted = true
for i = 2, #current do sorted = sorted and current[i-1] < current[i] end
check(sorted, "sorted unique inventory")
current[1] = "changed"
check(names.current_names()[1] ~= "changed", "defensive inventory")
check(names.is_known("capture_from_rule_start") and not names.is_shared_inventory_name("capture_from_rule_start"), "compatibility outside inventory")
check(c.canonical_action_helper_name("capture_from_rule_start") == "capture_slice", "compatibility canonical target")
local marks = names.complete_named_mark_names()
marks.clear_mark = nil
check(names.complete_named_mark_names().clear_mark, "defensive named mark view")
for _, pair in ipairs({{"=(x, 1)", "set"}, {"/(8, 2)", "num_div"}, {"+(1, 2)", "num_add"}}) do
  local r = resolve(pair[1])
  check(r.ok and r.contracts[1].canonical_name == pair[2], "canonical symbolic helper")
end
local unknown = resolve("cat(unknown_helper())")
check(not unknown.ok and #unknown.diagnostics == 1 and unknown.diagnostics[1].code == "unknown_helper", "nested unknown call")
local eager = resolve("with({ unknown_helper() })")
check(not eager.ok and eager.diagnostics[1].helper_name == "unknown_helper", "contextual body is resolved")
local inert = resolve("{|x| unknown_helper(x) }")
check(inert.ok and #inert.contracts == 0, "explicit callable body remains inert")
local original = parse('with("x", { return(value) })')
local normalized, contract = c.normalize_contextual_codeblock_call("function", original)
check(original.args[2].value.kind == "block_value" and normalized.args[2].value.kind == "codeblock_argument", "contextual conversion without source mutation")
check(contract.min_before_codeblock == 0 and contract.max_before_codeblock == 1, "builtin final slot")
local h = parse('with("x", { key: value })')
local same = c.normalize_contextual_codeblock_call("function", h)
check(same == h and h.args[2].value.kind == "hash_literal", "harray is not promoted")
local definition = {params={"value", "callback"}, arity=2, parameter_kinds=j.harray({callback="codeblock"})}
local user_contract = c.user_function_final_codeblock_contract(definition)
check(user_contract.min_before_codeblock == 1 and user_contract.max_before_codeblock == 1, "fixed final callback metadata")
definition.parameter_kinds.value = "codeblock"
check(c.user_function_final_codeblock_contract(definition) == nil, "ambiguous callback metadata rejected")
local signature = parse('{|head, ...tail| return(head) }')
check(signature.kind == "codeblock_literal" and signature.signature.rest_param == "tail", "fixed plus rest callable")
local bad_signature = resolve('{|x, x| return(x) }')
check(not bad_signature.ok and bad_signature.diagnostics[1].code == "duplicate_parameter", "duplicate callable parameter")
for _, newline in ipairs({"\n", "\r\n", "\r"}) do
  local block = p.parse_action_block('set(x, 1)' .. newline .. 'return(x)')
  check(#block.statements == 2, "physical newline separation")
end
local statements = p.parse_action_block("next; endif")
check(statements.statements[1].expr.kind == "call" and statements.statements[1].expr.name == "next", "standalone punctuation-light next")
check(parse("next").kind == "variable", "expression next remains a value read")
local chain = parse('" x ".trim')
check(chain.kind == "fluent_chain" and chain.calls[1].method == "trim", "terminal receiver parentheses omission")
local unicode = parse('  "é🐈" ')
check(unicode.kind == "string" and unicode.value == "é🐈" and unicode.source_span.start == 2 and unicode.source_span["end"] == 6, "Unicode scalar span")
local regex = parse([=[/a\/b/i]=])
check(regex.kind == "regex" and regex.pattern == [=[a\/b]=] and regex.flags == "i", "escaped regex delimiter and flags")
check(parse('/(a)/').kind == "regex", "grouped regex distinct from divide")
check(parse('/[/]/').kind == "raw_perl", "unescaped pattern delimiter is not admitted")
local escaped = parse([=["a\"b"]=])
check(escaped.kind == "string" and escaped.value == 'a"b', "escaped quote positive")
local opposite = parse([=['"|\s']=])
check(opposite.value == [=["|\s]=], "opposite quote and pattern escape positive")
local invalid_utf8 = pcall(p.parse_action_expression, '"' .. string.char(255) .. '"')
check(not invalid_utf8, "strict UTF-8 source")
print("FOCUSED_VALID_CONTROLS", checks)
for _, source in ipairs({[=["a" "b"]=], [=['a' 'b']=], [=["abc\"]=]}) do
  local expr = parse(source)
  local resolution = c.resolve_action_expression_contracts(expr)
  assert(expr.kind == "string" and resolution.ok)
  print("CONFIRMED_MALFORMED_ACCEPTANCE", j.encode(a.to_json(expr)))
end
for _, source in ipairs({[=[cat("a" "b")]=], [=[['a' 'b']]=], [=[value = "a" "b"]=]}) do
  local expr = parse(source)
  local resolution = c.resolve_action_expression_contracts(expr)
  assert(resolution.ok)
  print("NESTED_MALFORMED_ACCEPTANCE", j.encode(a.to_json(expr)))
end
assert(not package.loaded.linkedspec_regex_pcre2 and not package.loaded.linkedspec_filesystem_native)
print("PURE_MODULE_PROBE", "no native adapter loaded")
```

```bash
bash tools/project_data_run.sh python3 - <<'LUA_GROUP_THREE_PROBE'
from pathlib import Path
import re
card=Path('docs/knowledge/lua-contract-parser-reading-and-string-boundary-gap.md').read_text()
probe=re.search(r'^```lua\n(.*?)^```$',card,re.M|re.S)[1]
path=Path('.linkedspec-data/scratch/lua13/contract-parser-proof.lua')
path.parent.mkdir(parents=True,exist_ok=True)
path.write_text(probe)
LUA_GROUP_THREE_PROBE
bash tools/project_data_run.sh lua -v
bash tools/project_data_run.sh luajit -v
bash tools/project_data_run.sh lua .linkedspec-data/scratch/lua13/contract-parser-proof.lua
bash tools/project_data_run.sh luajit .linkedspec-data/scratch/lua13/contract-parser-proof.lua
```
