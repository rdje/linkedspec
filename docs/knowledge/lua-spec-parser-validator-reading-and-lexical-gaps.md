---
id: lua-spec-parser-validator-reading-and-lexical-gaps
title: Lua outer parser reading locates incomplete delimiters and lost literal state
answers:
  - "does Lua reject unclosed action blind and bare edge blocks"
  - "does Lua reject unfinished fluent argument parentheses"
  - "does Lua outer block parsing preserve regex braces"
  - "why does Lua compact regex brace code fail lifecycle validation"
  - "does Lua preserve quoted strings across physical block lines"
  - "do Lua parser and loaded engine options reject false"
  - "what did Lua startup reading group 22 cover"
date: 2026-09-13
status: confirmed-open repairs; exact reading complete
tags: [lua, parser, validator, loader, lexical, startup]
evidence: "LUA-STARTUP-READING.1.22; clean activation 65bd10925c633f1cee80ab25f03f7afa94d8daf6. Three exact ranges /1,500 fragments /44,459 bytes; eight complete windows. Root99 and standalone109 assertions pass per installed host, 416 total; 88 complete observations agree across hosts. Lua .2.24 owns six bounded lexical repair/proof children, .2.8.11/.12 parser/loaded options and .2.1 stale guidance; startup .54.3 retains shared regex recurrence. All source remains unchanged."
reverify:
  - "Run the exact managed replay below; observed malformed-source acceptance is not desired behavior."
  - "bash tools/run_lua_project_data.sh puc lua/test/root_rule_selection_core_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/root_rule_selection_core_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test/standalone_lifecycle_block_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/standalone_lifecycle_block_contract_test.lua"
  - "bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_standalone_lifecycle_block_contract.py"
---

## Exact reading

The ordered group digest remains
`f110fc4919916a4df56b309d98b4b2be58b619c30100ddb99bcf4887022198c3`.

| Repository path | Inclusive LF range | Bytes | Range SHA-256 |
| --- | --- | ---: | --- |
| `lua/src/linkedspec/spec_loader.lua` | 433–539 | 3727 | `277b454371da6589bfed09da973a08de32ec9d144f612b564c4f634586587088` |
| `lua/src/linkedspec/spec_parser.lua` | 1–1250 | 36541 | `a4c2f2112256fe150a2e1e6ee2f814518214ad28dd22b585390f7b3bb436e60b` |
| `lua/src/linkedspec/spec_validator.lua` | 1–143 | 4191 | `f8ce44d632e9a5cb3b091f82e77547395b7f8e0610a449f74a02e8565bd365cb` |

All eight windows were read without truncation: loader433–539; parser1–200,
201–400,401–600,601–800,801–1000,1001–1250; validator1–143.
Loader and spec parser reading finish; validator reading stops in duplicate-label
validation. Cumulative coverage is 22/51 groups, 28,651 fragments /1,124,280 bytes
and 40 complete files plus the partial validator. The targeted diagnostic read
of validator514–565 below gives no advance coverage credit to group23.

## Comprehension and canonical reconciliation

The loader lazily imports the spec-owned function parser to avoid a module cycle,
composes parse/validate/compile stages and derives engine identity from the request.
Caller engine options are copied; callers cannot override loaded spec_name/spec_path.
Pipeline JSON retains stable stage/code/request/path/detail fields.

The source parser uses Unicode rule-label recognition, simple/bounded mode parsing,
permissive raw fallback, grouped selectors and explicit/bare edge normalization.
Regex and quoted-parenthesis extraction preserve balanced compact literal arguments.
Header/body collection, attached when/otherwise, lifecycle/plain shorthand, markers
and fluent continuations compose typed body nodes. Strict source/source-id UTF-8
checks precede parsing. Empty/comment-only envelopes remain valid parser output so
validation owns no_rules_defined. The validator prefix defines typed errors,
reserved runtime symbols, lifecycle names and Unicode label checks before duplicates.

Retrieved [[lua-core-spec-parser]], [[lua-root-rule-selection-core]],
[[lua-staged-function-body-registry]], [[dart-spec-lexical-boundary-defects]],
[[julia-spec-lexical-boundary-defects]] and [[rust-body-parser-lexical-boundary-defects]]
before targeted reconciliation. Existing .2.1 gains the core parser card's historical
60/60 gate described as current; no old card or source is rewritten in this leaf.

## Incomplete outer delimiters

With Done defined first as `/x/`, these Top handler fragments reach EOF without a
closing brace yet compile and return7 on input `x`:

```text
-> Done { return(7)
=> Done { return(7)
Done { return(7)
```

`consume_block`391–443 returns accumulated code at EOF even if depth is nonzero.
The action/blind/bare adapters retain only their edge prefix as source, so the
normalized body has `return(7)` and no evidence of the missing outer close.
Lifecycle validation examines only CodeBlockBodyElementKind. The closed action
twin returns7; explicit `I {` and shorthand `{` EOF controls retain their outer
source and correctly fail unmatched-open validation. New .2.24.1 owns complete
edge block rejection without weakening those existing positive rejection controls.

`parse_fluent_chain`314–337 has another lossy fallback: failed parenthesis extraction
creates an empty-argument call and returns an empty remainder. Unfinished
`-> Done.return(7`, `=> Done.return(7` and `Done.return(7` compile to `return()`;
their observed runtime value is null with matched=true. `I.return(7` falls back to
a lifecycle marker plus body fluent and also compiles; that and a body-only
`.return(7` return null with matched=false. The balanced action twin returns7.
.2.24.2 owns all five source routes and continuation handling, preserving the
working compact quoted-opening/closing-parenthesis and whitespace controls.

## Regex braces: two independent boundaries

`I { return(matches("}", /}/)) }` becomes partial code
`return(matches("}", /` and raw `/)) }`; the grouped `/(})/` twin similarly
retains only the opening parenthesis before a raw suffix. Both fail ordinary
compilation after the outer parser has already truncated the action.
`scan_braces`368–389 handles quotes but has no regex state; .2.24.3 owns collection.

The compact `I.return(matches("}", /}/))` preserves the complete action text,
then fails with one unmatched close. `spec_validator.lua`514–536 counts braces
outside quotes without regex state, and539–561 applies that count to lifecycle
code/source. .2.24.4 owns this separate validation boundary. The diagnostic source
read does not complete the queued validator suffix. Shared startup .54.3 now
requires both Lua repairs alongside the existing backend owners and retains exact
public/carrier recurrence. No fresh other-backend result is claimed here.

`matches("x", /x/)` returns true. A plain quoted `"}"` return succeeds. Passing
`"}"` as the pattern to matches returns false, as required by the retrieved
[[lua-helper-regex-matches]] typed-regex contract and public helper catalog350–357:
`compile_helper_regex` rejects values without its private regex identity before
native compilation. This is a non-regex operand control, not a new matches defect
or evidence that quoted strings are portable replacement patterns.

## Multiline quoted text

For actual newlines inside quoted text, compact `I.return("a\nb")` and
`I.return("a\n}b")` retain the full code and return those exact strings.
Equivalent braced block collection loses quote state at the physical line boundary.
The `}b` case closes the outer block inside the string, leaving partial
`return("a` and raw `b") }`; compilation reports that tail at original line2
although it came from line3. The brace-free multiline twin retains an extra outer
`}` in its code, compiles as raw_perl ActionIR and fails at execution.

`scan_braces` starts each physical line with no retained quote state; consume_block
calls it independently per line. On the continuation line, a real closing string
quote is treated as a new opening quote, or an earlier `}` is treated as structural.
.2.24.5 owns quote/escape state across lines, exact string content and remainder
line attribution. .2.24.6 composes independent source/AST/diagnostic/carrier proof
for all five lexical repair leaves. Compact twins establish current multiline
string support; this does not propose new syntax or modify string semantics.

## Parser and loaded-engine option defaults

parse_spec plus loaded-engine function/method forms accept false options after
`or {}` at spec_parser1182 and spec_loader489/507. Omitted/empty options pass,
true/zero/text retain typed parse or loader errors. Parsed rule count remains1 and
loaded execution remains7 for successful controls. The exact loaded fixture is
repository-local and contains one zero-regex Top -> Done returning7 plus Done `/x/`.
Existing .2.8 gains implementation .2.8.11 and independent route proof .2.8.12,
preserving derived identity and valid option fields.

## Proof scope and exact replay

Unchanged root99 and standalone109 assertions pass per installed PUC5.5.1 and
LuaJIT host, 416 total. The 88 complete new observations comprise26 parser cases
and18 option cases per host; decoded payloads agree completely. They are separate
from declared suite assertion counts. New boundary observations exercise direct
native compilation/runtime and loaded option aliases, not fresh malformed-source
reconstructed/generated/emitted/CLI/MCP routes. No reference, full CI, dependency
build or supported-PUC5.4 admission is newly claimed. Earlier PUC observation
failures and all repair prerequisites remain unchanged.
Neutral root passes7 complete /0 pending /54 mutations; standalone passes9 placements,
4 duplicate forms,6 ownership cases,3 malformed twins,6 runtime routes and14 mutations.
Those ledgers remain governance, not fresh six-runtime execution.

The initial23 source cases were retained; three compact-multiline/quoted-text controls
were added after the braced multiline outcomes required isolation. Both complete
26-case payloads were rerun and verified. No source or permanent consumer changed.

```bash
bash tools/project_data_run.sh python3 - <<'LUA_SPEC_PARSER_READING_22'
from pathlib import Path
root=Path('.linkedspec-data/scratch/lua122')
root.mkdir(parents=True,exist_ok=True)
(root/'parser-boundaries.lua').write_text('local ls=require("linkedspec");local json=ls.json;local rows=json.array()\nlocal cases={\n {"multiline_compact",\'Top::\\n I.return("a\\nb")\\n\'},\n {"multiline_compact_brace",\'Top::\\n I.return("a\\n}b")\\n\'},\n {"quoted_text",\'Top::\\n I { return("}") }\\n\'},\n {"compact_open",\'Top::\\n I.return("(")\\n\'},\n {"compact_close",\'Top::\\n I.return(")")\\n\'},\n {"compact_space",\'Top::\\n I.return ("ok")\\n\'},\n {"regex_brace",\'Top::\\n I { return(matches("}", /}/)) }\\n\'},\n {"regex_grouped",\'Top::\\n I { return(matches("}", /(})/)) }\\n\'},\n {"regex_compact",\'Top::\\n I.return(matches("}", /}/))\\n\'},\n {"regex_plain",\'Top::\\n I { return(matches("x", /x/)) }\\n\'},\n {"quoted_brace",\'Top::\\n I { return(matches("}", "}")) }\\n\'},\n {"lifecycle_closed",\'Top::\\n I { return("ok") }\\n\'},\n {"lifecycle_eof",\'Top::\\n I { return("ok")\\n\'},\n {"shorthand_eof",\'Top::\\n { return("ok")\\n\'},\n {"action_closed",\'Done:\\n /x/\\nTop::\\n -> Done { return(7) }\\n\'},\n {"action_eof",\'Done:\\n /x/\\nTop::\\n -> Done { return(7)\\n\'},\n {"blind_eof",\'Done:\\n /x/\\nTop::\\n => Done { return(7)\\n\'},\n {"bare_eof",\'Done:\\n /x/\\nTop::\\n Done { return(7)\\n\'},\n {"action_fluent_closed",\'Done:\\n /x/\\nTop::\\n -> Done.return(7)\\n\'},\n {"action_fluent_eof",\'Done:\\n /x/\\nTop::\\n -> Done.return(7\\n\'},\n {"blind_fluent_eof",\'Done:\\n /x/\\nTop::\\n => Done.return(7\\n\'},\n {"bare_fluent_eof",\'Done:\\n /x/\\nTop::\\n Done.return(7\\n\'},\n {"lifecycle_fluent_eof",\'Top::\\n I.return(7\\n\'},\n {"body_fluent_eof",\'Top::\\n .return(7\\n\'},\n {"multiline_quote",\'Top::\\n I { return("a\\n}b") }\\n\'},\n {"multiline_quote_control",\'Top::\\n I { return("a\\nb") }\\n\'},\n}\nfor _,case in ipairs(cases) do\n local row=json.harray({case=case[1],source=case[2]});local ok,spec=pcall(ls.parse_spec,case[2]);row.parsed=ok\n if ok then\n  row.ast=ls.spec_ast.to_json(spec);local compiled_ok,compiled=pcall(ls.compile_spec,spec);row.compiled=compiled_ok\n  if compiled_ok then local ran,result=pcall(function()return ls.runtime_parse(ls.runtime_engine(compiled),"x")end);row.ran=ran\n   if ran then row.value=result.value;row.matched=result.matched else row.runtime_error=tostring(result)end\n  else row.compile_error=tostring(compiled) end\n else row.parse_error=tostring(spec)end\n rows[#rows+1]=row\nend\nio.write(json.encode(rows),"\\n")\n')
(root/'option-boundaries.lua').write_text('local ls=require("linkedspec");local json=ls.json;local rows=json.array()\nlocal loaded=ls.load_and_compile_spec(ls.path_spec_request("loaded.spec"),ls.spec_load_options({cwd=".linkedspec-data/scratch/lua122"}))\nlocal operations={\n {"parse",function(o)return #ls.parse_spec("Top::\\n I { return(7) }\\n",o).rules end},\n {"loaded_function",function(o)return ls.runtime_parse(ls.create_loaded_spec_engine(loaded,o),"x").value end},\n {"loaded_method",function(o)return ls.runtime_parse(loaded:create_engine(o),"x").value end},\n}\nfor _,op in ipairs(operations)do for _,case in ipairs({{"absent"},{"empty",{}},{"false",false},{"true",true},{"zero",0},{"text","wrong"}})do\n local ok,value=pcall(op[2],case[2]);rows[#rows+1]=json.harray({operation=op[1],case=case[1],ok=ok,value=ok and value or json.null,error=ok and json.null or tostring(value)})\nend end\nio.write(json.encode(rows),"\\n")\n')
(root/'loaded.spec').write_text('Top::\n -> Done { return(7) }\nDone:\n /x/\n')
(root/'verify-parser.py').write_text('from pathlib import Path\nimport json\nroot=Path(\'.linkedspec-data/scratch/lua122\')\nrows={h:json.loads((root/(\'parser-\'+h+\'.json\')).read_text()) for h in [\'puc\',\'luajit\']}\noptions={h:json.loads((root/(\'options-\'+h+\'.json\')).read_text()) for h in [\'puc\',\'luajit\']}\nassert rows[\'puc\']==rows[\'luajit\'] and options[\'puc\']==options[\'luajit\']\nvalues={\'multiline_compact\':\'a\\nb\',\'multiline_compact_brace\':\'a\\n}b\',\'quoted_text\':\'}\',\'compact_open\':\'(\',\'compact_close\':\')\',\'compact_space\':\'ok\',\'regex_plain\':True,\'quoted_brace\':False,\'lifecycle_closed\':\'ok\',\'action_closed\':7,\'action_eof\':7,\'blind_eof\':7,\'bare_eof\':7,\'action_fluent_closed\':7,\'action_fluent_eof\':None,\'blind_fluent_eof\':None,\'bare_fluent_eof\':None,\'lifecycle_fluent_eof\':None,\'body_fluent_eof\':None}\nerrors={\'regex_brace\':"SpecValidationException: rule \'Top\': unrecognized body syntax at line 2: /)) }",\'regex_grouped\':"SpecValidationException: rule \'Top\': unrecognized body syntax at line 2: )/)) }",\'regex_compact\':"SpecValidationException: rule \'Top\' has unbalanced braces: 1 unmatched close",\'lifecycle_eof\':"SpecValidationException: rule \'Top\' has unbalanced braces: 1 unmatched open",\'shorthand_eof\':"SpecValidationException: rule \'Top\' has unbalanced braces: 1 unmatched open",\'multiline_quote\':"SpecValidationException: rule \'Top\': unrecognized body syntax at line 2: b\\") }"}\nfor host,data in rows.items():\n assert len(data)==26 and len({r[\'case\'] for r in data})==26\n by={r[\'case\']:r for r in data};assert set(by)==set(values)|set(errors)|{\'multiline_quote_control\'}\n for name,r in by.items():\n  assert r[\'parsed\'] is True and r[\'ast\'][\'source_id\']==\'inline\' and r[\'ast\'][\'functions\']==[]\n  top=[rule for rule in r[\'ast\'][\'rules\'] if rule[\'header\'][\'label\']==\'Top\'];assert len(top)==1 and top[0][\'header\'][\'is_top\'] is True\n  body=top[0][\'body\'];kinds=[e[\'kind\'] for e in body]\n  if name in errors:\n   assert r[\'compiled\'] is False and r[\'compile_error\']==errors[name] and \'ran\' not in r and \'value\' not in r\n  else:\n   assert r[\'compiled\'] is True\n   if name==\'multiline_quote_control\':\n    assert r[\'ran\'] is False and r[\'runtime_error\']=="RuntimeInterpreterException: unsupported runtime ActionIR kind \'raw_perl\'"\n    assert kinds[0][\'code\']==\'return("a\\nb") }\'\n   else:\n    assert r[\'ran\'] is True and r[\'value\']==values[name] and r[\'matched\']==(name not in [\'lifecycle_fluent_eof\',\'body_fluent_eof\'])\n  if name in [\'action_eof\',\'blind_eof\',\'bare_eof\']:\n   assert len(body)==1 and kinds[0][\'code\']==\'return(7)\' and \'{\' not in body[0][\'source\']\n  if name in [\'action_fluent_eof\',\'blind_fluent_eof\',\'bare_fluent_eof\',\'lifecycle_fluent_eof\',\'body_fluent_eof\']:\n   calls=kinds[-1].get(\'fluent_chain\',kinds[-1].get(\'calls\'));assert calls==[{\'args\':\'\',\'method\':\'return\'}]\n  if name in [\'regex_brace\',\'regex_grouped\']:\n   assert kinds[0][\'code\']==(\'return(matches("}", /\' if name==\'regex_brace\' else \'return(matches("}", /(\')\n   assert kinds[1]=={\'kind\':\'raw\',\'text\':\'/)) }\' if name==\'regex_brace\' else \')/)) }\'}\n  if name==\'regex_compact\':assert kinds[0][\'code\']==\'return(matches("}", /}/))\' and len(body)==1\n  if name==\'multiline_quote\':assert kinds[0][\'code\']==\'return("a\' and kinds[1]=={\'kind\':\'raw\',\'text\':\'b") }\'} and body[1][\'line\']==2\n for r in options[host]:\n  valid=r[\'case\'] in [\'absent\',\'empty\',\'false\'];assert r[\'ok\']==valid\n  if valid:assert r[\'value\']==(1 if r[\'operation\']==\'parse\' else 7) and r[\'error\'] is None\n  else:assert r[\'value\'] is None and r[\'error\']==(\'SpecParseException(line 1): parse options must be a table\' if r[\'operation\']==\'parse\' else \'SpecLoaderError: loaded spec engine options must be a table\')\n assert len(options[host])==18\nprint(\'PASS 88 complete two-host observations: 52 parser/compiler/runtime cases and 36 parser/loaded-engine option cases; exact lexical failures and valid controls retained.\')\n')
LUA_SPEC_PARSER_READING_22
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua122/parser-boundaries.lua > .linkedspec-data/scratch/lua122/parser-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua122/parser-boundaries.lua > .linkedspec-data/scratch/lua122/parser-luajit.json
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua122/option-boundaries.lua > .linkedspec-data/scratch/lua122/options-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua122/option-boundaries.lua > .linkedspec-data/scratch/lua122/options-luajit.json
bash tools/project_data_run.sh python3 .linkedspec-data/scratch/lua122/verify-parser.py
```

The preservation audit retains 1,397 prior source/card/decision/history files and
2,518 of 2,524 prior task nodes exactly; only six explicitly owned reading/repair
records change. Exactly nine pending repair nodes are added. All 78 prior known
limitation headings remain, with three new headings; the parked authoring tree,
prior chronology and all 99 Lua source files stay byte-identical. All four embedded
payloads equal the executed files, and exact range hashes plus the independent
99-file/51-group coverage replay pass at 22 read groups.

Knowledge regeneration reports 1,108 facts /8,880 keys. Memory remains 60 lines;
change/engineering hot logs are 368/298 lines (25,779/22,348 bytes), without required
rollover. Memory, both histories, whitespace and rendered book checks pass.
The existing search-index warning is 10,094,701 bytes and stays startup .41.9-owned.
Normal doctrine hooks govern this focused landing; no canonical CI or push is claimed.
