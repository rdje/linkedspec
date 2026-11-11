# Readonly reader landing correction

The first reader passed with actual exit0 and empty stderr; its exact source is
recoverable from first-review.py.gz. Its original command, output and
sealed-identities.json remain unchanged. The staged whitespace check then exited2
for a new blank line at EOF in that source. The exact failure log and exit survive
in landing-whitespace-failure.*.

The current review.py removes that whitespace and explicitly recovers its first-use
source through the gzip alias when reading the original seal. It also verifies the
separate qualified-identities.json before recovery. No SDK, normal, fixture, source
oracle or original output changes. run_review_qualified.py retains this separate
actual invocation, source identities and full channels: exit0, empty stderr and
the same188 groups/940 pairs/14 effective controls. REVIEW.md remains the sealed
original review narrative; this file records the later landing correction.

Both seal/capture writers remain one-shot. The readonly review.py is the public
historical recovery command; it does not execute current SDK code.
