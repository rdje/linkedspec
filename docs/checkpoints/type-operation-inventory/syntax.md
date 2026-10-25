# Value syntax and operation roles

Owner: `TYPE-REFERENCE-BOOK.1.2.1.1`. This is the non-call syntax portion of the
working operation inventory. Free helpers/aliases and receiver/result-type
methods have separate owners `.1.2.1.2` and `.1.2.1.3`; this document makes no
complete method-family, backend-parity or execution-coverage claim.

Canonical sources below are repository-root paths. The authority/model ledger is
`docs/checkpoints/type-reference-inventory/README.md`; its original captures are
historical, not commands to refresh before implementing features.

## Value model

One identifier holds its current scalar, array, harray or codeblock value.
Strings, numbers, booleans and null are distinguishable scalar values; integer
and real notation do not create separate binding namespaces. Arrays and harrays
retain the kinds of their contained values. A returned value is an input to the
next compatible operation; its source binding's former kind is not an authority
for method dispatch. This does not make every operation a receiver method.

Authority: `capability_conformance/uniform_binding_contract.json:policy`,
`capability_conformance/scalar_text_contract.json`,
`capability_conformance/scalar_numeric_contract.json`,
`capability_conformance/logical_helper_contract.json` and
`capability_conformance/callable_codeblock_contract.json`.

## Non-call forms

| Form | Syntax role and result | Effects, boundaries and authority |
| --- | --- | --- |
| `"text"`, `'text'` | String literal; one scalar string. | Quoted content is data. String escape/physical-newline behavior has its own backend limits; do not infer cross-backend escape equivalence from quote recognition. Formal grammar Primitive Values; scalar-text contract. |
| `42`, `-1`, `3.14` | Numeric literal; one scalar number. | These examples describe literal notation. Numeric-string normalization, finite-domain checks and helper aliases belong to the numeric contract/helper inventory; arbitrary host infix arithmetic is a separate raw surface. |
| `true`, `false` | Boolean literal; typed boolean. | Exact words only. Neither a numeric comparison result nor strings `"true"`/`"false"` are interchangeable with boolean identity. Logical-helper and scalar-text contracts. |
| `undef` | Null literal; JSON null at serialization. | A present null binding is distinct from an absent binding for mutation. Uniform-binding and scalar-text contracts. |
| `name` | Read the identifier's current typed value. | No alternate scalar/array/hash namespace. A read does not create nested containers; callable-looking names follow call resolution instead of becoming literal strings. Uniform-binding contract. |
| `[v1, v2, ...]`, `[]` | Array shape literal; one array preserving element kinds. | Elements evaluate in source order. Explicit flat helpers can splice in supported list-consuming contexts; a nested array value otherwise remains an element. Book Shape Value Literals and uniform-binding constructor policy. |
| `{ key : value, ... }`, `{}` | Harray shape literal; one harray. | Key and value expressions evaluate in source order; bare keys read bindings, quoted keys are fixed text. Empty braces are an empty harray. `=>` is retired in this value syntax. Formal grammar/Helper Catalog Shape Value Literals. |
| `{ statements; expression }` | Eager expression-valued block; final value or block-local explicit return. | Executes immediately, including on assignment RHS. A shape with top-level `:` has harray precedence. A `return(...)` exits this expression block, not the outer rule/function. Book expression-valued block contract. |
| `{|| body }`, `{|a, b| body }`, `{|prefix, ...rest| body }` | Deferred codeblock literal; inert callable value. | Plain-data signature/body/spans, no captured lexical environment. Construction does not execute body. Invocation/callback forms below supply dynamic context. Callable-codeblock/signature contracts. |
| `base[key]`, `base[key][index]...` | Direct access path; selected typed value. | Read-only traversal; missing paths yield null instead of autovivifying. Selector/coercion and signed-index scope follow the actual backend's current contract. This spelling does not establish arbitrary post-expression indexing or a dot-method. Book Direct nested access and read-purity sections. |
| `array_name[-n]` | Existing-array tail selection: resolved index `size - n`, requiring a nonnegative result. | Integer negative reads/writes have implementations and focused checks across the current backends under `.1.2.17`; broad portable admission `.17.7` remains deferred. Strings/fractions are not newly admitted negative write indices; do not merge read coercion with write selector validation. Book signed selector section and task17. |
| `name = value` | Binding assignment; stores and yields the current typed value. | RHS once; any current binding kind can be replaced. Statement position drops the result. Helper/symbol spellings `set(...)`/`=(...)` are separate call inventory entries. Uniform-binding `set_result`. |
| `name += value` | Array append assignment; updated typed array snapshot. | Existing wrong kinds fail; absent target may initialize an array. Stored/returned mutation results must follow the mutation snapshot contract rather than alias a later write. Uniform-binding policy and book Array append. |
| `base[key][index]... = value` | Typed path mutation; detached updated root, not only the leaf. | Selectors once left-to-right, then RHS once; structural building uses the post-effect snapshot, publishes atomically and returns the updated root. Dense nonnegative append is allowed; negative selectors require an existing in-range array. Existing null/wrong kind and gaps fail without partial path publication. Book nested-write contract and backend write-vivification facts. |
| `(name = value)`, `(base[key] = value)`, `(name += value)` | Grouped ordinary assignment value or compatible mutation receiver. | Perl ordinary value lowering uses balanced assignment groups, including stored RHS/helper operands and function locals (`.1.2.19`). Its public AST can remain raw; deferred codeblocks still reject raw grouped assignments. Do not infer admission of all parenthesized host expressions. |

## Invocation and structural roles

| Form | Role and result | Context, argument and continuation boundaries |
| --- | --- | --- |
| `fn name(a, b) { body }` | Named function definition; establishes a callable by name, not a value expression or receiver method. | Unique names and fixed arity; fresh function-local scope. Definition shells use the published first-party spec grammar. Formal grammar User Functions; callable-signature contract. |
| `fn name(prefix, ...rest) { body }` | Variadic named-function definition. | At most one final rest identifier; fixed arguments first, extras become a fresh typed array, including an empty array. No overload/default/named-argument/host-splat admission. Callable-signature contract. |
| `fn name(value, callback: codeblock) { body }` | Final contextual-codeblock parameter declaration. | The annotation says callable value kind, not the literal's parameter signature. Final block attachment is metadata-governed; arbitrary trailing braces are not blanket callable syntax. Callable-codeblock contract/ADR0032. |
| `name(arg1, arg2, ...)` | Resolved helper/control, named-function or bound-codeblock invocation. | Resolution precedence: control, helper, registered user function, bound callable slot, typed non-callable failure, unresolved name. Function/callable arguments evaluate once left-to-right before parameter binding; copied temporary parameter/rest slots restore afterward. Non-parameter caller slots remain live for deferred calls. Callable-codeblock/signature contracts. |
| `helper(args) { body }`, `receiver.method(args) { body }` | Metadata-approved final contextual callback. | Uses the receiving callable's declared block policy and scoped context. Eager blocks, explicit deferred literals and attached control branches remain distinct. `with` has a temporary present `value` binding; nested scopes restore it on success/error. CallableContract metadata and book trailing-block contract. |
| `receiver.method(args).next(args)` | Built-in fluent receiver call chain. | Receiver becomes the built-in's effective first operand; user-defined functions do not automatically become methods. Continuations depend on actual supported result-type links and existing terminal guards. Full per-method dispatch and missing transitions belong to `.1.2.1.3`/`.23`. |
| `receiver.map_leaves!() { ... }` and named array-end mutation forms | Governed mutation receiver syntax, not a universal postfix operator. | `map_leaves!` is the sole current bang method, on an addressable bare binding. Mutation guards, callback results, snapshots and typed wrong-kind diagnostics follow the named operation's contract. Enumerate actual methods in the receiver inventory; punctuation alone does not add variants. Map-leaves mutation contract and Helper Catalog. |
| Newline / `;` between top-level DSL statements | Statement separator, not a value operation or type method. | Newlines inside protected strings/patterns/nested expressions remain payload. Same-line adjacent statements need `;`. Complete first-line numeric slash calls retain their established boundary. Book statement separators and `.1.2.21`. |

## Exclusions and compatibility boundaries

- Exact `array(IDENTIFIER)`/`hash(IDENTIFIER)` selectors are removed as reads,
  namespaces, mutation targets and authority. This includes the superficially
  similar single-bare constructor intent; use `[value]` or a proper harray shape.
  Other contracted constructor forms are call entries, not replacements for
  alternate namespaces. Authority: uniform-binding `selector_retirement` and
  `constructor_policy`.
- Retired `:name` scalar slots use bare `name`; old `{ key => value }` value
  literals use `:`. Rule graph `=>` edges and generated host hashes have different
  owners and are not retired by the harray-value rule.
- Slash patterns are contextual operands of regex-aware helpers. Legacy Perl
  standalone/assigned patterns can evaluate to a match result against host `$_`;
  they do not create a portable reusable regex value. `.1.2.21` preserves complete
  multiline raw payloads only when the first physical line remains raw;
  recognized first-line DSL expressions retain their old boundary.
- Quoted helper-looking text, raw host compatibility, private parser intrinsics,
  rule/lifecycle/graph syntax and historical aliases are not admitted public
  generic methods merely because a scanner recognizes their names. Their
  classification belongs to the helper/receiver inventory and existing owners.
- This inventory does not close backend behavior gaps or deferred validation.
  Existing defect/task owners remain authoritative; a syntax entry is not an
  execution or parity claim.
