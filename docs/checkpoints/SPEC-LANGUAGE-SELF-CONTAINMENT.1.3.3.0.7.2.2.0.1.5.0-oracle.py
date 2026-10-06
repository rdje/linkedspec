"""Independent literal events, arguments, original intervals and channel oracle."""


def check(document, authored):
    rows = document["cases"]
    cases = authored["cases"]
    assert [row["id"] for row in rows] == [case["id"] for case in cases], "complete original case order"
    events = frames = 0
    for row, case in zip(rows, cases):
        assert row["action"] == case["action"], "exact original source"
        expected_frames = [
            {"source": case["action"], **statement} for statement in case["statements"]
        ]
        assert row["statement_frames"] == expected_frames, "independent original statement intervals"
        frames += len(expected_frames)
        assert [item["contract"] for item in row["rows"]] == [
            item["contract"] for item in case["rows"]
        ], "complete selected contract order"
        for result, expected in zip(row["rows"], case["rows"]):
            public, private = result["public"], result["private"]
            assert public["result"] == private["result"]["events"] == expected["expected_events"], "literal original events and arguments"
            assert private["result"]["source_origins"] == [], "original dedicated source-origin gap"
            assert public["calls"] == private["calls"], "exact original callback channels"
            for captured in (public, private):
                assert captured["returned_array"] is True, "actual dispatcher returned-array identity"
                assert captured["identity"] == [
                    {"event": True, "args": True} for _ in expected["expected_events"]
                ], "actual dispatcher event and argument identities"
                split_calls = [call for call in captured["calls"]
                               if call["callback"] == "split_action_ir_statements"]
                assert len(split_calls) == 1 and split_calls[0]["args"] == [case["action"]], "original single split callback"
            for event, (start, end) in zip(expected["expected_events"], expected["original_spans"]):
                assert case["action"][start:end] == event["raw"], "independently authored original event interval"
            assert len(expected["original_spans"]) == len(expected["expected_events"]), "complete original scalar intervals"
            events += len(expected["expected_events"])
    assert [row["id"] for row in document["toolbox"]] == [
        case["id"] for case in authored["toolbox"]
    ], "complete Toolbox population"
    for row, case in zip(document["toolbox"], authored["toolbox"]):
        assert row["action"] == case["action"], "original Toolbox source"
        assert row["failure"] is None and row["parser_built"] is True, "successful actual Toolbox build"
        assert row["internal_stdout"] == row["internal_stderr"] == "", "quiet Toolbox channels"
        assert isinstance(row["descriptor"], dict), "complete descriptor metadata channel"
        assert isinstance(row["substitution"], str) and row["substitution"], "complete substitution channel"
        assert isinstance(row["dump"], str) and row["dump"], "complete parser-source channel"
    return {"events": events, "statement_frames": frames, "source_origins": 0,
            "cases": len(cases), "compiler_cases": len(document["toolbox"])}
