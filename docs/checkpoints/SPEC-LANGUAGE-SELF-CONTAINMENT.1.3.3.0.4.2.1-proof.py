"""Actual isolated recovery/RED controls and read-denied historical audit replay.

Only managed scratch is written. JSON on stdout is the retained observation.
Neither original logs nor historical tracked captures are changed.
"""
import builtins
import copy
from contextlib import contextmanager
import importlib.util
import io
import json
import os
from pathlib import Path
import warnings
import zipfile

ROOT = Path(__file__).resolve().parents[2]
DECODER = "tests/language-readiness/recover_objective_audit_inputs.py"
AUDITOR = "tests/language-readiness/verify_objectives.py"
PRODUCER = "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-archive.py"


def load(name, source):
    spec = importlib.util.spec_from_file_location(name, ROOT / source)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


@contextmanager
def read_write_guard(original_paths):
    counts = {"original_log_attempts": 0, "tracked_write_attempts": 0}
    old_builtin, old_io = builtins.open, io.open

    def guard(delegate):
        def opened(file, mode="r", *args, **kwargs):
            if isinstance(file, (str, bytes, os.PathLike)):
                path = Path(os.fsdecode(file)).resolve()
                if path in original_paths:
                    counts["original_log_attempts"] += 1
                    raise ValueError("original log read denied")
                if any(flag in mode for flag in "wax+") and path.is_relative_to(ROOT) and not \
                        path.is_relative_to(ROOT / ".linkedspec-data"):
                    counts["tracked_write_attempts"] += 1
                    raise ValueError("tracked write denied")
            return delegate(file, mode, *args, **kwargs)
        return opened

    builtins.open, io.open = guard(old_builtin), guard(old_io)
    try:
        yield counts
    finally:
        builtins.open, io.open = old_builtin, old_io


def main():
    recovery = load("objective_recovery", DECODER)
    audit = load("objective_audit", AUDITOR)
    producer = load("objective_archive_producer", PRODUCER)
    manifest_data = recovery.read_input(recovery.MANIFEST)
    archive_data = recovery.read_input(recovery.ARCHIVE)
    manifest = json.loads(manifest_data)
    recovered = recovery.validate(manifest_data, archive_data)
    controls = []

    def reject(name, action, reason):
        try:
            action()
        except ValueError as error:
            recovery.require(str(error) == reason, "unrelated rejection: " + name)
            controls.append({"name": name, "reason": reason})
        else:
            raise ValueError("control accepted: " + name)

    def encoded(value):
        return json.dumps(value).encode()

    def rebound(data):
        value = copy.deepcopy(manifest)
        value["archive"].update(bytes=len(data), sha256=recovery.digest(data))
        return encoded(value)

    def changed_zip(kind):
        output = io.BytesIO()
        rows = manifest["entries"]
        with warnings.catch_warnings(record=True):
            with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
                for index, row in enumerate(rows):
                    if kind == "missing" and index == 0:
                        continue
                    data = recovered[row["path"]]
                    if index == 0 and kind == "content":
                        data = bytes([data[0] ^ 1]) + data[1:]
                    compression = zipfile.ZIP_STORED if index == 0 and kind == "stored" \
                        else zipfile.ZIP_DEFLATED
                    archive.writestr(row["member"], data, compress_type=compression, compresslevel=9)
                if kind == "extra":
                    archive.writestr("extra", b"unexpected")
                if kind == "duplicate":
                    archive.writestr(rows[0]["member"], recovered[rows[0]["path"]])
        return output.getvalue()

    damaged = bytes([archive_data[0] ^ 1]) + archive_data[1:]
    reject("actual-archive-byte", lambda: recovery.validate(manifest_data, damaged),
           "archive identity mismatch")
    for kind, reason in (("missing", "ZIP membership mismatch"),
                         ("extra", "ZIP membership mismatch"),
                         ("duplicate", "ZIP membership mismatch"),
                         ("content", "ZIP member content mismatch"),
                         ("stored", "ZIP member metadata mismatch")):
        data = changed_zip(kind)
        reject("actual-ZIP-" + kind, lambda: recovery.validate(rebound(data), data), reason)
    truncated = archive_data[:-1]
    reject("actual-ZIP-truncation", lambda: recovery.validate(rebound(truncated), truncated),
           "ZIP end record mismatch")
    for kind in ("membership", "size", "path", "census"):
        value = copy.deepcopy(manifest)
        if kind == "membership":
            value["entries"].pop()
        elif kind == "size":
            value["entries"][0]["bytes"] += 1
        elif kind == "path":
            value["entries"][0]["path"] = "../outside"
        else:
            value["census"]["sha256"] = "0" * 64
        reason = {"path": "invalid relative path", "census": "manifest census identity mismatch"}.get(
            kind, "manifest differs from independent census")
        reject("actual-manifest-" + kind, lambda: recovery.validate(encoded(value), archive_data), reason)

    base = recovery.SCRATCH + f"proof-{os.getpid()}"
    healthy = base + "/healthy"
    root = recovery.restore(healthy, recovered)
    restored_hashes = {name: recovery.digest(recovery.read_input((root / name).relative_to(ROOT).as_posix()))
                       for name in recovered}
    recovery.require(restored_hashes == {row["path"]: row["sha256"] for row in manifest["entries"]},
                     "isolated restoration identity mismatch")
    reject("existing-destination", lambda: recovery.restore(healthy, recovered),
           "restore destination already exists")
    for destination in ("../outside", "/outside", base + "/../outside"):
        reject("outside-destination-" + str(len(controls)),
               lambda: recovery.restore(destination, recovered), "invalid relative path")
    reject("unowned-destination", lambda: recovery.restore("docs/restore-output", recovered),
           "restore destination outside owned scratch")
    (ROOT / base / "symlink-target").mkdir()
    (ROOT / base / "symlink-parent").symlink_to("symlink-target", target_is_directory=True)
    reject("symlink-ancestor", lambda: recovery.restore(base + "/symlink-parent/new", recovered),
           "symlink directory rejected")
    (ROOT / base / "symlink-root").symlink_to("symlink-target", target_is_directory=True)
    reject("symlink-destination", lambda: recovery.restore(base + "/symlink-root", recovered),
           "symlink destination rejected")

    original_reader = audit.read_relative

    def reader(name):
        if name in recovered:
            path = root / name
            try:
                return recovery.read_input(path.relative_to(ROOT).as_posix())
            except FileNotFoundError:
                raise ValueError("restored log unavailable: " + name) from None
        recovery.require(not name.startswith(".linkedspec-data/"), "unowned local input rejected")
        return original_reader(name)

    audit.read_relative = reader
    original_paths = {(ROOT / name).resolve() for name in recovered}
    with read_write_guard(original_paths) as guard:
        first = sorted(recovered)[0]
        reject("original-log-denial-instrument", lambda: (ROOT / first).read_bytes(),
               "original log read denied")
        reject("tracked-write-denial-instrument", lambda: (ROOT / AUDITOR).open("wb"),
               "tracked write denied")
        recovery.require(guard == {"original_log_attempts": 1, "tracked_write_attempts": 1},
                         "denial instrument did not observe actual attempts")
        guard.update(original_log_attempts=0, tracked_write_attempts=0)
        rebuilt_manifest, rebuilt_archive = producer.capture(recovery, reader)
        recovery.require(rebuilt_manifest == manifest_data and rebuilt_archive == archive_data,
                         "isolated deterministic archive capture differs")
        report = audit.audit_evidence(reader)
        audit_controls = audit.falsify(report)
        summary = reader("docs/language-readiness/objective-reconciliation.md").decode()
        audit.verify_summary(report, summary)
        reject("summary-recovery-inflation", lambda: audit.verify_summary(
            report, summary.replace("| 28 / 68 |", "| 29 / 68 |", 1)), "summary route mismatch: perl")
        missing = root / first
        backup = missing.with_name(missing.name + ".held")
        missing.rename(backup)
        try:
            reject("actual-restored-input-absence", lambda: audit.audit_evidence(reader),
                   "restored log unavailable: " + first)
        finally:
            backup.rename(missing)
        recovery.require(guard == {"original_log_attempts": 0, "tracked_write_attempts": 0},
                         "audit escaped isolated read/write boundary")
        healthy_guard = dict(guard)

    inputs = set(report["checkpoints"]) | set(report["latest_source_inputs"])
    inputs.update((DECODER, AUDITOR, PRODUCER, Path(__file__).relative_to(ROOT).as_posix(),
                   recovery.ARCHIVE, recovery.MANIFEST, recovery.CENSUS,
                   recovery.CENSUS_PREFIX + "census.py",
                   "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1-verification.json",
                   "docs/language-readiness/objective-reconciliation.md",
                   audit.EVALUATED_VALUES_TABLE, audit.SCALAR_NUMERIC_TABLE, audit.DROP_GENERATED_TABLE,
                   audit.COUNT_FIRST_TABLE))
    retained_inputs = {name: recovery.digest(recovery.read_input(name)) for name in sorted(inputs)}
    print(json.dumps({"version": 1, "owner": recovery.OWNER, "restored_inputs": len(recovered),
        "restored_bytes": sum(map(len, recovered.values())), "restored_hashes": restored_hashes,
        "archive": manifest["archive"], "controls": controls, "audit_controls": audit_controls,
        "isolated_deterministic_capture": True,
        "healthy_audit_guard": healthy_guard, "audit_report": report,
        "tracked_inputs": retained_inputs,
        "limits": "Exact selected artifact recovery and historical evidence integrity; runtime executions remain their dated per-leaf proof. No bridge/dispatcher, complete D/P, other backend or format admission."},
        indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
