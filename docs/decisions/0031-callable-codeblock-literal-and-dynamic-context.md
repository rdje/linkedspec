# 0031 — Codeblock values use `{|params| body }` literals and dynamic caller context

- Date: 2026-07-12
- Status: accepted
- Tags: architecture, codeblock, callable, literal, dynamic-scope, functions, hash, actionir, portability

## Context

LinkedSpec names four value kinds: scalar, array, harray, and codeblock. Current block values can execute
immediately, and selected helper/method surfaces accept immediate trailing blocks, but a user cannot initialize a
codeblock variable and invoke it later. Bare braces are already shared by two current value forms:

- `{}` and `{ key_expr : value_expr }` are harray literals; and
- non-empty `{ statements }` without a top-level hash pair is an immediately evaluated block expression.

The director requires an initializer that is unambiguous against harrays and makes a bound codeblock callable as
`cb(...)`. Candidate forms included an explicit `codeblock(args) { ... }` constructor, `->(args) { ... }`, an
anonymous `fn(args) { ... }`, and a brace-pipe literal. The initializer also forces a scope decision: lexical
closure capture, captured snapshots, or execution against the caller's current context.

## Decision

1. A callable codeblock literal uses an exact `{|` opener, a pipe-delimited positional signature, and a closing
   brace:

   ```text
   cb = {|left, right|
     return(cat(left, right))
   }

   result = cb("a", "b")
   ```

   There is no whitespace between `{` and the opening `|`. The closing signature `|` separates parameters from
   the body. `{|| body }` is the zero-parameter form.
2. Parameters follow the callable rules adopted by ADR 0030: zero or more identifiers and at most one final
   `...rest`. Calls are positional-only. A literal owns one typed `callable_signature`; it is not a host closure,
   function, coderef, or vararg object.
3. Brace forms remain prefix-unambiguous:

   - `{|params| body }` constructs a deferred callable codeblock;
   - `{}` and `{ key_expr : value_expr }` construct harrays; and
   - `{ statements }` is the existing immediately evaluated block expression.

   Constructing a codeblock stores its signature, typed ActionIR body, source, and spans. It does not execute the
   body.
4. `cb(args)` invokes a variable whose current value is a codeblock. Current helpers/controls and registered user
   functions keep static resolution precedence, so assigning a codeblock to a colliding name does not shadow a
   governed callable. An unbound name retains the unknown-call diagnostic; a bound non-codeblock produces a typed
   not-callable diagnostic.
5. Accepted arguments evaluate exactly once, left to right, in the caller's current context. Parameter and rest
   names receive recursively copied values in temporary bindings; all prior bindings for those names are restored
   on success or failure. The rest value is a fresh typed array.
6. The initial execution model is dynamic caller context, not lexical closure capture. Nonparameter reads observe
   their values at call time. Nonparameter mutation uses the caller's current runtime stores and remains visible
   after the call. No environment is captured at codeblock construction.
7. `return(expr)` is local to the codeblock invocation. Otherwise the final expression is the result. Results are
   ordinary values and may feed compatible receiver chains; standalone calls execute and discard their result.
   Direct or mutual active codeblock recursion is initially rejected with typed callable identity and cycle data.
8. Generic final-codeblock arguments remain signature-governed. Attached `call(args) { body }` and the existing
   contextual parenthesized final-block spelling normalize to the same canonical codeblock-argument node when the
   callable contract accepts it. An explicit `{|params| body }` can also be passed as a value. Harray literals are
   never promoted to codeblocks. `with` remains an ordinary block-taking helper rather than a parser exception.
   ADR 0032 later supplies the missing declaration: a final `name: codeblock` parameter, with no nested argument
   list; the supplied codeblock value owns its own `{|params| ...}` signature.
9. Lexical closure capture is not part of version 1. Adding capture-by-reference or capture-by-snapshot semantics
   requires a new decision, task-tree owner, neutral fixtures, and every-backend parity proof.

## Consequences

- The neutral AST needs a versioned codeblock-literal node containing source/spans, typed body, and callable
  signature. Native and generated states serialize data, never host callable objects.
- Every backend needs deterministic `{|` recognition before its current harray/immediate-block brace classifier.
- Runtime call resolution must distinguish governed static names, bound codeblocks, bound non-codeblocks, and
  unknown calls without host-language fallback.
- Dynamic context deliberately permits delayed bodies to observe later caller state. Temporary parameter bindings
  do not leak, while other mutations are caller-visible. This matches the current immediate callback model more
  closely than silently introducing closures.
- Direct harray syntax and current immediate block values remain source- and behavior-compatible.
- A machine-readable contract and independent checker precede parser/runtime implementation. Perl is the reference
  rollout, followed by Rust, Dart, Julia, and dependency-complete Lua routing.

## Links

- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`.11.1`)
- Prior variadic signature: ADR `0030`
- Existing immediate callback record: `docs/knowledge/terse-trailing-block-argument-mvp.md`
- Existing generic correction: `docs/knowledge/generic-trailing-codeblock-argument-correction.md`
- Final parameter declaration clarification: ADR `0032`
- Existing brace ground truth: `docs/knowledge/terse-expression-valued-blocks-ground-truth.md`
