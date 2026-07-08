---
id: split-boundary-marker-action-timing
title: "Split-boundary markers update after their matched action site; read @capture_slice and @mark effects from a later action or use helper calls for in-block timing"
answers:
  - "why did @capture_slice include the opener or move too late"
  - "how should docs demonstrate @capture_slice with @mark"
  - "when are split-boundary markers visible to action code"
  - "why should marker examples read from a later slot"
  - "what is the verified capture mark marker timing shape"
date: 2026-07-08
status: confirmed
tags: [spec-language, mdbook, helpers, capture-mark, markers, SPEC-LANG-REFERENCE]
evidence: "SPEC-LANG-REFERENCE.6 generated-source probes showed current Perl emits split-boundary marker updates after action dispatch for the effective action site: @capture_slice updates the anonymous $IPOS boundary there, and @mark(name) writes the named mark for later same-rule reads. The verified public example uses an opener action plus @capture_slice/@mark, then reads capture_slice(), capture_from(...), and capture_between(...) from the closing action under seek mode."
---

# Split-Boundary Marker Action Timing

**Confirmed 2026-07-08 (`SPEC-LANG-REFERENCE.6`).** Marker forms such as
`@capture_slice` and `@mark(name)` are placement-sensitive rule members, not
ordinary action-block helpers. In current Perl generated handlers, their effects
are visible after the matched action site has completed, so an action attached to
the same site should not expect to read a marker that is being written by that
same site.

Use this verified teaching shape when documentation needs both marker syntax and
capture/mark helper reads:

```text
Top::AND
 => MarkerBody

MarkerBody:AND
 /foo\(/
 @capture_slice
 @mark(body_start)
 /[A-Za-z]+/
 /\)/
 -> MarkerBody[0] {
   opened = 1;
 }
 -> MarkerBody[2] {
   mark_match_start(close_start);
   return(hash(
     "anonymous", capture_slice(),
     "named", capture_from(body_start),
     "between", capture_between(body_start, close_start),
     "body_start", mark_pos(body_start),
     "close_start", mark_pos(close_start)
   ))
 }
```

With `parse_mode => "seek"`, input `foo(alpha)` returns:

```json
[{"anonymous":"alpha","between":"alpha","body_start":4,"close_start":9,"named":"alpha"}]
```

For exact timing inside an action or lifecycle block, prefer helper-call forms
such as `start_capture_slice()` and `mark_here(name)`. Use marker forms when the
grammar slot itself is the boundary and the later read happens from a later
action.

## Links

- Task tree: [[SPEC-LANG-REFERENCE]] (leaf `.6`)
- Public placement page: `docs/linkedspec-book/src/dsl/action-and-lifecycle-placement.md`
- Public helper reference: `docs/linkedspec-book/src/dsl/source-boundary-helper-reference.md`
