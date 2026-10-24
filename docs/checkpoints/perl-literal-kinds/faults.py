"""Physical runtime inverses with complete semantic RED and restored GREEN runs."""
import json
import os
import re
import subprocess
import common as c
import context
import capture

CODEBLOCK = "perl/LinkedSpec/CodeblockRuntime.pm"
BINDING = "perl/LinkedSpec/BindingRuntime.pm"


def once(raw, old, new):
    assert raw.count(old) == 1, old
    return raw.replace(old, new, 1)


def section(raw, start, end):
    left = raw.index(start)
    right = raw.index(end, left)
    return raw[left:right]


def execute(name):
    epoch = context.snapshot()
    c.write_new(name + "-inputs.json.gz", dict(context=epoch,
        producer=c.read(c.PREFIX + "faults.py"), worker=c.read("t/callable_codeblock_literal_contract.t")))
    run = c.run(["bash", "tools/project_data_run.sh", "env", "PERL5LIB=",
        "LINKEDSPEC_LITERAL_KIND_OBSERVE=1", "prove", "-v", "-Iperl", "t/callable_codeblock_literal_contract.t"])
    unchanged = c.unchanged(epoch["inputs"])
    c.write_new(name + "-runs.json.gz", dict(run=run, inputs_unchanged=unchanged))
    assert unchanged
    result = capture.summarize(run, 37)
    assert re.search(r"^1\.\.28$", c.decode(run["stdout_base64"]).decode(), re.MULTILINE), "Incomplete TAP reach"
    return dict(exit_code=run["returncode"], **result)


def main():
    original = {path: c.read(path) for path in (CODEBLOCK, BINDING)}
    healthy = {path: c.decode(item["base64"]) for path, item in original.items()}
    accepted = {path: subprocess.check_output(["git", "show", c.BASE + ":" + path], cwd=c.ROOT)
        for path in original}
    runtime = healthy[CODEBLOCK]
    number = section(runtime, b" if ($kind eq 'number') {", b" return $node->{value} if $kind eq 'string';")
    copy = section(runtime, b"sub _copy_value {", b"sub _value_kind {")
    old_copy = section(accepted[CODEBLOCK], b"sub _copy_value {", b"sub _value_kind {")
    private = healthy[BINDING]
    for kind in ("POK", "IOK", "NOK"):
        private = once(private, ("B::SVf_" + kind + "()").encode(), ("B::SVp_" + kind + "()").encode())
    guarded = b"  return 0 + substr($source, 0) if defined($source) && !ref($source)\n   && $source =~ /\\A-?[0-9]+(?:\\.[0-9]+)?\\z/;"
    variants = {
        "accepted-runtime-inverse": accepted,
        "numeric-payload-inverse": {CODEBLOCK: once(runtime, number, b" return 0 + $node->{value} if $kind eq 'number';\n")},
        "boolean-inverse": {CODEBLOCK: once(runtime,
            b"return $node->{value} ? JSON::PP::true : JSON::PP::false if $kind eq 'boolean';",
            b"return $node->{value} ? 1 : 0 if $kind eq 'boolean';")},
        "storable-copy-inverse": {CODEBLOCK: once(runtime, copy, old_copy)},
        "private-cache-inverse": {BINDING: private},
        "numeric-source-guard-bypass": {CODEBLOCK: once(runtime, guarded,
            b"  return 0 + substr($source, 0) if defined($source) && !ref($source);")},
        "aliased-copy": {CODEBLOCK: once(runtime, copy, b"sub _copy_value {\n return $_[0]\n}\n\n")},
        "precision-with-kind-preserved": {CODEBLOCK: once(runtime,
            b"return 0 + substr($source, 0) if defined($source)",
            b"return 0 + substr($source eq '1000000000000000.5' ? '1000000000000000.0' : $source, 0) if defined($source)")},
        "fresh-token-necessity": {CODEBLOCK: once(runtime,
            b"return 0 + substr($source, 0) if defined($source)", b"return 0 + $source if defined($source)")},
    }
    epoch = context.snapshot()
    c.write_new("fault-controller-inputs.json.gz", dict(context=epoch,
        producer=c.read(c.PREFIX + "faults.py"), healthy_sources=original,
        variants={name: {path: dict(base64=c.encode(raw), sha256=c.sha(raw)) for path, raw in changed.items()}
            for name, changed in variants.items()},
        optional_finite_diagnostic="fresh-token-necessity earns detection credit only if its actual run is RED; no necessity is inferred from a finite GREEN."))
    results = {}
    for name, changed in variants.items():
        assert all(c.read(path) == item for path, item in original.items())
        fault = None
        try:
            for path, raw in changed.items():
                c.source(path).write_bytes(raw)
            fault = execute("fault-" + name)
        finally:
            for path, item in original.items():
                c.source(path).write_bytes(c.decode(item["base64"]))
                os.chmod(c.source(path), item["mode"])
        assert all(c.read(path) == item for path, item in original.items())
        restored = execute("restore-" + name)
        assert restored["exit_code"] == 0 and not restored["mismatches"] and not restored["instrument_errors"], restored
        results[name] = dict(fault=fault, restored=restored)
        print(name, json.dumps(dict(fault_exit=fault["exit_code"], public_mismatches=len(fault["mismatches"]),
            restored_exit=restored["exit_code"]), sort_keys=True), flush=True)
    c.write_new("fault-controller-runs.json.gz", dict(results=results,
        sources_restored=all(c.read(path) == item for path, item in original.items())))
    for name, result in results.items():
        if name != "fresh-token-necessity":
            assert result["fault"]["exit_code"] != 0, ("Ineffective required inverse", name)
    print("All required inverses are RED; every complete restored consumer is GREEN.", flush=True)


if __name__ == "__main__":
    main()
