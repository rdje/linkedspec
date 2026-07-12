# =============================================================================
# spec.spec — self-hosted description of the LinkedSpec `.spec` file format
# =============================================================================
#
# This grammar is written in the `.spec` DSL itself and describes the `.spec`
# language exactly as recognized by the hardcoded reference parser
# `perl/LinkedSpec/BootstrapSpec/Core.pm`. It is the self-hosting surface: a
# `.spec` grammar that parses `.spec` files.
#
# STRUCTURE (mirrors BootstrapSpec::Core)
# ---------------------------------------
# A `.spec` file is a sequence of rule PARAGRAPHS. A paragraph starts at a rule
# header (`Name:` / `Name::`) and runs until the next rule header. The hardcoded
# bootstrap driver (`SPEC_ROOT`) scans tokens and starts a new paragraph each
# time it sees a rule header, appending every other token to the current
# paragraph. This grammar reproduces that exactly:
#
#   spec_file        the top rule: owns the paragraph accumulators, dispatches to
#                    one rule per paragraph part, and starts a new paragraph at
#                    every rule_header (the SPEC_ROOT group-at-header rule).
#     rule_header      `Name:` / `Name::` + optional mode   -> { type: rule, ... }
#     regex_anchor     `/pattern/`                          -> { type: regex }
#     action_block     `-> A|B[i] { code }`                 -> { type: action_edge }
#     action_fluent    `-> Name[i].method(args) { blk }`    -> { type: action_edge }
#     action_bare      `-> Name[i]`                         -> { type: action_edge }
#     blind_block      `=> Child { code }`                  -> { type: blind_edge }
#     blind_fluent     `=> Child.method(args) { blk }`      -> { type: blind_edge }
#     blind_bare       `=> Child`                           -> { type: blind_edge }
#     lifecycle_block  `Marker { code }`  (I LS LE E EX IT LX) -> { type: lifecycle }
#     lifecycle_fluent `Marker.method(args) { blk }`        -> { type: lifecycle }
#     variadic_function_definition `fn name(args, ...rest) { body }` -> { type: function_definition }
#     function_definition `fn name(args) { body }`           -> { type: function_definition }
#     split_marker     `@capture_slice` / `@mark(name)`     -> { type: split_marker }
#     comment          `# ...`                              (skipped, like SPEC_ROOT)
#
# Each part rule is its own rule, connected to spec_file by an action edge; the
# part rules read their match through `entry_*` helpers (they are entered by
# dispatch). The output of `spec_file` is an array of paragraphs, each an array
# of typed part nodes — the same paragraph grouping the bootstrap produces.
#
# RULE-HEADER MODE -> node_type (documented; emitted raw in the `mode` field):
#   (none)  default        |  &      AND          |  AND      AND_EXPLICIT
#   |       OR (single)    |  +      REP_PLUS      |  AND+     REP_AND_PLUS
#   *       REP_STAR       |  ?      REP_OPT       |  AND{n,m} REP_AND_BOUNDED
#   OR      REP_OR_EXPLICIT|  OR+    REP_OR_PLUS   |  OR{n,m}  REP_OR_BOUNDED
#
# AUTHORING NOTES
#   - Slot order is significant: block and fluent edge forms precede the bare
#     form so the longest valid token wins, matching the bootstrap's start-token
#     ordering. The same applies to lifecycle block-vs-fluent.
#   - Block-bearing slots capture the full balanced, string-aware `{ ... }` with
#     a recursive named group so the cursor advances past the block and its
#     interior is never re-scanned as top-level tokens.
#   - Fluent-chain joins use `\s*` (not `[ \t]*`) so multiline method chains are
#     fully consumed, matching the bootstrap.
#
# EXTENSION-SURFACE POLICY
#   spec.spec is the intended change surface for `.spec` language evolution: new
#   syntax should be described here first. Changing the hardcoded bootstrap
#   grammar (`BootstrapSpec/Core.pm`) for language changes is exception-only and
#   must be justified in the commit message and DEVELOPMENT_NOTES.md.
#   Function definitions (`fn name(args) { ... }`) follow the same rule: the
#   accepted permanent grammar owner is this self-hosted grammar. The hardcoded
#   bootstrap parser must not become the lasting owner; the Perl reference
#   currently uses a temporary pre-bootstrap registry bridge for this surface.
# =============================================================================

spec_file::
 I {
  set(array(paragraphs), array());
  set(array(current), array());
  started = 0
 }
 -> rule_header {
  if(started) {
   push(array(paragraphs), copy(array(current)));
   set(array(current), array())
  }
  started = 1;
  push(rule_header, current)
 }
 -> regex_anchor     { push(regex_anchor, current) }
 -> action_block     { push(action_block, current) }
 -> action_fluent    { push(action_fluent, current) }
 -> action_bare      { push(action_bare, current) }
 -> blind_block      { push(blind_block, current) }
 -> blind_fluent     { push(blind_fluent, current) }
 -> blind_bare       { push(blind_bare, current) }
 -> lifecycle_block  { push(lifecycle_block, current) }
 -> lifecycle_fluent { push(lifecycle_fluent, current) }
 -> variadic_function_definition { push(variadic_function_definition, current) }
 -> function_definition { push(function_definition, current) }
 -> split_marker     { push(split_marker, current) }
 -> comment          { next() }
 LX {
  if(started) {
   push(array(paragraphs), copy(array(current)))
  }
  return(copy(array(paragraphs)))
 }

# ---- rule header: `Name:` (body rule) or `Name::` (top rule) + optional mode --
rule_header: /(\w++)[ \t]*(::|:)[ \t]*((?:&|\||\+|\*|\?|OR\+|OR\{[^}]++\}|OR|AND\+|AND\{[^}]++\}|AND)?)/
 I {
  top = 0;
  if(str_eq(entry_group(1), "::")) { top = 1 }
  return(hash("type", "rule", "label", entry_group(0), "top", top, "mode", entry_group(2)))
 }

# ---- regex literal: `/pattern/` (outer slashes stripped, inner pattern kept) --
regex_anchor: /(?<!\\)\/((?:\\.|[^\/\\])*?)(?<!\\)\//
 I.return(hash("type", "regex", "pattern", entry_group(0)))

# ---- action edge with a code block: `-> A | B[i] { code }` --------------------
action_block: /->[ \t]*((?:\w+[ \t]*(?:\[[ \t]*\d+[ \t]*\][ \t]*)?)(?:[ \t]*\|[ \t]*\w+[ \t]*(?:\[[ \t]*\d+[ \t]*\][ \t]*)?)*)[ \t]*(?<blkAB>\{(?:[^{}"']++|"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|(?&blkAB))*\})/
 I.return(hash("type", "action_edge", "targets", trim(entry_group(0)), "code", entry_group(1)))

# ---- action edge with a fluent chain: `-> Name[i].method(args) { block }` -----
action_fluent: /->[ \t]*(\w+)[ \t]*(?:\[[ \t]*\d+[ \t]*\][ \t]*)?(?<chAF>(?:\s*\.\s*\w+(?<prnAF>\s*\((?:[^()"']++|"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|(?&prnAF))*\))?)+)(?:\s*(?<blkAF>\{(?:[^{}"']++|"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|(?&blkAF))*\}))?/
 I.return(hash("type", "action_edge", "target", entry_group(0), "fluent", "1", "raw", entry_text()))

# ---- bare action edge: `-> Name` or `-> Name[i]` -----------------------------
action_bare: /->[ \t]*(\w+)(?:\[[ \t]*(\d+)[ \t]*\])?/
 I.return(hash("type", "action_edge", "target", entry_group(0), "index", entry_group(1)))

# ---- blind-call edge with a code block: `=> Child { code }` -------------------
blind_block: /=>[ \t]*(\w+)[ \t]*(?<blkBB>\{(?:[^{}"']++|"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|(?&blkBB))*\})/
 I.return(hash("type", "blind_edge", "target", entry_group(0), "code", entry_group(1)))

# ---- blind-call edge with a fluent chain: `=> Child.method(args) { block }` ---
blind_fluent: /=>[ \t]*(\w+)(?<chBF>(?:\s*\.\s*\w+(?<prnBF>\s*\((?:[^()"']++|"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|(?&prnBF))*\))?)+)(?:\s*(?<blkBF>\{(?:[^{}"']++|"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|(?&blkBF))*\}))?/
 I.return(hash("type", "blind_edge", "target", entry_group(0), "fluent", "1", "raw", entry_text()))

# ---- bare blind-call edge: `=> Child` ----------------------------------------
blind_bare: /=>[ \t]*(\w+)/
 I.return(hash("type", "blind_edge", "target", entry_group(0)))

# ---- lifecycle / code block: `Marker { code }` (I LS LE E EX IT LX, or any word)
lifecycle_block: /(\w++)[ \t]*(?<blkLB>\{(?:[^{}"']++|"(?:\\.|[^"])*+"|'(?:\\.|[^'])*+'|(?&blkLB))*+\})/
 I.return(hash("type", "lifecycle", "marker", entry_group(0), "code", entry_group(1)))

# ---- lifecycle / code with a fluent chain: `Marker.method(args) { block }` ----
lifecycle_fluent: /(\w++)(?<chLF>(?:\s*\.\s*\w++(?<prnLF>\s*\((?:[^()"']++|"(?:\\.|[^"])*+"|'(?:\\.|[^'])*+'|(?&prnLF))*+\))?+)++)(?:\s*(?<blkLF>\{(?:[^{}"']++|"(?:\\.|[^"])*+"|'(?:\\.|[^'])*+'|(?&blkLF))*+\}))?+/
 I.return(hash("type", "lifecycle", "marker", entry_group(0), "fluent", "1", "raw", entry_text()))

# ---- user function definition: `fn name(args) { body }` ----------------------
variadic_function_definition: /fn[ \t]+([A-Za-z_]\w*)\s*\((?:([A-Za-z_]\w*(?:\s*,\s*[A-Za-z_]\w*)*)\s*,\s*)?\.\.\.([A-Za-z_]\w*)\)\s*(?<blkVFN>\{(?:[^{}"']++|"(?:\\.|[^"])*+"|'(?:\\.|[^'])*+'|(?&blkVFN))*+\})/
 I {
  return({
   "type" : "function_definition",
   "version" : 2,
   "name" : entry_group(0),
   "signature" : {
    "kind" : "callable_signature",
    "version" : 1,
    "positional_params" : entry_group(1).split(/\s*,\s*/).trim_each().filter_nonempty(),
    "rest_param" : entry_group(2),
    "min_arity" : count(entry_group(1).split(/\s*,\s*/).trim_each().filter_nonempty()),
    "max_arity" : undef
   },
   "body" : entry_group(3)
  })
 }

function_definition: /fn[ \t]+([A-Za-z_]\w*)\s*\(([A-Za-z_]\w*(?:\s*,\s*[A-Za-z_]\w*)*)?\)\s*(?<blkFN>\{(?:[^{}"']++|"(?:\\.|[^"])*+"|'(?:\\.|[^'])*+'|(?&blkFN))*+\})/
 I.return(hash("type", "function_definition", "name", entry_group(0), "params", entry_group(1), "body", entry_group(2)))

# ---- split / mark marker: `@capture_slice`, `@capture_from_here`, `@move_pos`, `@mark(name)`
split_marker: /@[ \t]*(?:capture_slice|capture_from_here|move_pos|mark[ \t]*\([ \t]*(\w+)[ \t]*\))/
 I.return(hash("type", "split_marker", "marker", entry_text(), "name", entry_group(0)))

# ---- comment: `# ...` to end of line (skipped, like the bootstrap SPEC_ROOT) --
comment: /#.*/
 I.return(hash("type", "comment", "text", entry_text()))
