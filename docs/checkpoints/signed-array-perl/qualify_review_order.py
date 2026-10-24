"""Keep original reviewer failure and distinguish map-field order from effects."""
import common as c
import oracle

names = ("inverse", "indexed-reader", "nested-reader", "result-reader", "float-spelling",
    "underflow-diagnostic", "missing-array", "aliased-result")
differences = []
for name in names:
    run = c.load("verified-fault-" + name + "-runs.json.gz")
    plan = c.load("verified-fault-" + name + "-inputs.json.gz")["plan"]
    for route in ("native", "generated"):
        actual = oracle.check(plan, route, run["observations"][route])
        prior = run["failures"][route]
        assert len(actual) == len(prior)
        for left, right in zip(actual, prior):
            assert left["id"] == right["id"] and sorted(left["reasons"]) == sorted(right["reasons"])
        if actual != prior:
            differences.append(dict(name=name, route=route, original=prior, replay=actual))
c.write_new("review-order-qualification.json.gz", dict(
    producer=c.read(c.PREFIX + "qualify_review_order.py"), original_reviewer=c.read(c.PREFIX + "review.py"),
    oracle=c.read(c.PREFIX + "oracle.py"), actual_log=c.read(".linkedspec-data/verification/signed-perl-review.log"),
    differences=differences,
    qualification="Sorted-key packet serialization changes error-map iteration order. The first reviewer compared derived diagnostic-field reason lists in that incidental order. Every actual case and reason membership/multiplicity is identical. Normalize only these field-name reports; preserve authored case order, actual outcomes, scalar kinds, diagnostic fields and ordered effect arrays. Original source, failure and observations remain unchanged."))
print("Reason-order-only qualification:", len(differences), "route reports; all memberships exact")
