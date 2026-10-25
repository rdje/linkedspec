---
id: terse-type-method-surface-inventory
title: "Perl value/helper contracts"
answers:
  - "can Perl last run inside deferred codeblocks"
  - "what receiver methods already exist in the terse type method surface"
  - "does string substr already work as a method"
  - "which helpers should remain function only or statement only"
  - "what did SPEC-FORMAT-TERSE.7.1 inventory"
  - "which method backfill leaf follows SPEC-FORMAT-TERSE.7.1"
  - "do block yielded values and user function returns have their own method table"
  - "why did a later callback change an earlier Perl array element"
  - "do Perl hash keys and callable arguments retain evaluated values"
  - "can Perl num_add run inside a deferred codeblock"
  - "does Perl drop_keys warn for a single literal key"
  - "why does Perl drop_keys ignore flat_array keys"
  - "why can a later drop key callback change an earlier key"
  - "why can a later numeric operand change an earlier value"
  - "can Perl numeric comparison receivers continue into cat"
  - "can Perl sum run inside a deferred codeblock"
  - "why does invalid aggregate receiver arity reach a host function"
  - "why did prose reflow change otherwise identical rendered book HTML"
  - "how is the generated mdBook search-index reference compared"
  - "why did checkpoint input snapshots grow recursively"
  - "how do checkpoint chunks restore data and reject nested Git roots"
  - "can Perl count and first run inside deferred codeblocks"
  - "can Perl sorted and take run inside a deferred codeblock"
  - "why do sorted numbers become strings after a container copy"
  - "which task owns deferred last count first indexed writes and registered sorted"
  - "why do malformed fluent arguments leak a Perl array-reference error"
  - "why do private count captures expect old defined guards"
  - "why did registered sorted pipelines lose function parameters"
  - "why does a reused book renderer import the wrong document module"
  - "when are private Storable integer caches unsafe for scalar kind checks"
date: 2026-10-25
status: bounded Perl; inventory pending
tags: [spec-format-terse, method-chaining, mdbook]
evidence: "Type checkpoints; pipelines11."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/deferred_last_contract.t"
  - "bash tools/project_data_run.sh prove -Iperl t/scalar_numeric_contract.t"
  - "bash tools/run_python_project_data.sh docs/checkpoints/rust-numeric-boundaries/review_book.py"
---

# Value model and bounded Perl helper execution

Bindings retain evaluated constructor keys/values and arguments. Deferred reads
use caller slots; updates copy on write. [[perl-generic-final-codeblock-normalization]].

Scalar/aggregate Numeric policies differ. Shapes precede effects; comparisons/
reducers terminate. Aggregates take one array, receivers none. Scalar min/max
evaluates before rejection. Perl checks each decimal: empty sum0, othersundef;
Rust filters differently. Reducer95:
[[perl-numeric-reducer-string-result-kinds]]. Boolean35 is repaired through22;
Unicode20/constructor94 remain separate.

Deferred sorted/take have free/receiver forms. Lexical sort retains numeric/string
kinds through clones/indexes. Literal22 distinguishes public validity from private
Storable caches: [[perl-codeblock-boolean-literal-kind-drift]].
take defaults1; integer spelling only; negative/invalid0; oversized clamp.
Nonarrays yield[], skip count; independent source/results.
Deferred count/first/last: one free operand, no receiver args; receivers terminate.
Nonarrays yield0/undef; first/last retain kinds/callables; bad shapes skip effects.
Array chains reuse the bridge; emitted values avoid DSL reparsing.
length takes no args and terminates; bad shapes/continuations skip effects.
12 writes and14 last are implemented.
Fluent args require arrays before preflight. Three private count goldens retain
native captures; current guards execute against arrays/nonarrays. No backend admission.

drop_keys copies keys/splices, keeps null diagnostics and FATAL-warning silence.
c053c9dcf inventories substr/typed receivers; references pending.

Accepted7 retains its15 body-whitespace differences. Current numeric55.1
reverification retains90 outputs/four body-whitespace differences and verifies
both HTML and searcher fallback references against the complete decoded index.
Decoder: `docs/checkpoints/type-deferred-indexed-writes/search_data.py`.
Readonly proof: `docs/checkpoints/rust-numeric-boundaries/review_book.py`;
only document-body whitespace is normalized; all other fields/URLs and
literal code/script/style remain checked. Semantic/URL controls reject.

Context hash-gates gzip/37 verified32MiB chunks and three byte/mode aliases;
nested-Git guards. Recursive originals:49ce.

Book proof reuse: a historical renderer prepended its own directory and caused
document to resolve to its older module. Literal22 retains the pre-epoch setup
failure without product RED credit; preload local context and restore sys.path
in finally when importing only pure render helpers.
