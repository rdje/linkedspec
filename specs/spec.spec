# spec.spec — Self-hosted LinkedSpec grammar
#
# This grammar parses .spec files into their structural elements: rule labels,
# modes, regex anchors, action edges, blind-call edges, code blocks, split
# markers, lifecycle markers, fluent chains, conditional markers, and helper
# function calls.
#
# ============================================================================
# EXTENSION-SURFACE POLICY (PHASE7-SELF-HOSTED-SPEC.5)
# ============================================================================
#
# spec.spec is the REQUIRED change surface for .spec language evolution.
# Any proposal to extend, modify, or deprecate .spec syntax MUST:
#
#   1. Be authored in spec.spec first — add or modify rules here to
#      capture the new syntax before touching any implementation code.
#
#   2. Pass the full regression gate with language_agnostic_ready_ratio
#      at 1.0000 (all rules using only canonical ActionIR constructs).
#
#   3. Include regression coverage proving the spec compiles and the
#      generated parser recognizes the new construct.
#
# Touching the bootstrap grammar (BootstrapSpec/Core.pm or related
# hardcoded parse rules) for .spec language changes is EXCEPTION-ONLY.
# Exceptions require explicit justification documented in the commit
# message and in DEVELOPMENT_NOTES.md, and must satisfy at least one of:
#
#   (a) The construct cannot be expressed in spec.spec due to a known
#       bootstrapping gap (e.g., comment/blank-line skipping requires
#       a parse-level skip loop that the generated parser does not
#       currently support).
#
#   (b) The bootstrap grammar and spec.spec parity requires a
#       coordinated update where the bootstrap change is the mechanical
#       enabler for the spec.spec change (e.g., a new regex feature
#       that spec.spec itself uses).
#
# ============================================================================
# KNOWN BOOTSTRAPPING GAPS
# ============================================================================
#
# 1. Comment/blank-line skipping: body_element cannot skip comments/blank lines.
#    Workaround: strip leading comments before parsing.
#
# 2. AND+ + LX infinite loop: The LX lifecycle marker in AND+ repetition
#    triggers loop re-entry. Workaround: use E instead of LX for exit.
#
# ============================================================================

spec_file::AND+
 -> rule_paragraph

I {declare(array, rules)}
LS {declare(scalar, retv)}
LE { if(scalar(retv)); push_value(array(rules), scalar(retv)); endif() }
E {return(hash("rules", array(rules)))}


rule_paragraph:AND /(\w+)[ \t]*(::|:)[ \t]*(\S*)[ \t]*(.*)/
I { declare(scalar, label=entry_group(1)); declare(scalar, colon=entry_group(2)); declare(scalar, is_top=0); if(matches(scalar(colon), /^::$/o)); declare(scalar, is_top=1); endif(); declare(scalar, mode_raw=entry_group(3)); declare(scalar, rest=entry_group(4)); declare(scalar, mode=""); if(matches(scalar(mode_raw), /^$/o)); declare(scalar, mode=""); else(); if(matches(scalar(mode_raw), /^(?:AND|OR)(?:\+|\{\d+(?:,\d+)?\})?$/o)); declare(scalar, mode=scalar(mode_raw)); else(); if(matches(scalar(mode_raw), /^[&|+*?]$/o)); declare(scalar, mode=scalar(mode_raw)); else(); declare(scalar, mode=""); if(length(scalar(rest))); declare(scalar, rest=concat(scalar(mode_raw), " ", scalar(rest))); else(); declare(scalar, rest=scalar(mode_raw)); endif(); endif(); endif(); endif(); return(hash("type", "rule_header", "label", scalar(label), "is_top", scalar(is_top), "mode", scalar(mode), "rest", scalar(rest), "body", array())) }
 -> body_element


# body_element matches individual body elements: regexes, edges, markers, etc.
# Each alternative uses per-regex I{} blocks. The REP handler (via return→assignment
# transformation in SpecEntry.pm) collects all matches into an array.
body_element:*
 /(?<!\\)\/(?:\\.|[^\/\\])*?(?<!\\)\//
  I { return(hash("type", "regex", "value", match_text())) }
 /->[ \t]*(\w+)(?:\[(\d+)\])?/
  I { declare(scalar, target=entry_group(1)); declare(scalar, idx=0); if(entry_group(2)); declare(scalar, idx=entry_group(2)); endif(); return(hash("type", "edge", "target", scalar(target), "index", scalar(idx))) }
 /=>[ \t]*(\w+)/
  I { return(hash("type", "blind_edge", "target", entry_group(1))) }
 /@[ \t]*(?:capture_slice|capture_from_here|move_pos|mark[ \t]*\([ \t]*\w+[ \t]*\))/
  I { return(hash("type", "split_marker", "marker", match_text())) }
 /-\?[ \t]+\w+\b/
  I { return(hash("type", "conditional_marker", "text", match_text())) }
 /(?:I|LS|LE|LX|E|EX|IT)\b/
  I { return(hash("type", "lifecycle_marker", "marker", match_text())) }
 /\.[ \t]*\w+/
  I { return(hash("type", "fluent_chain", "text", match_text())) }
 /\w+[ \t]*[\(\{\.]/
  I { return(hash("type", "body_code", "text", match_text())) }
 /(?<!\\)\{/
  I { return(hash("type", "code_block")) }
