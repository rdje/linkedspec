"""Publish the measured backlog in fast-forward batches, preserving normal hooks."""
import hashlib
import json
from pathlib import Path
import subprocess
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[3]
LOGS = ROOT / ".linkedspec-data/logs"


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True).strip()


def pack_size(base, target):
    source = subprocess.Popen(["git", "rev-list", "--objects", base + ".." + target],
                              cwd=ROOT, stdout=subprocess.PIPE)
    packed = subprocess.Popen(["git", "pack-objects", "--stdout"], cwd=ROOT,
                              stdin=source.stdout, stdout=subprocess.PIPE)
    source.stdout.close()
    size = 0
    while raw := packed.stdout.read(1024 * 1024):
        size += len(raw)
    assert packed.wait() == 0 and source.wait() == 0
    return size


def remote_tip(ref):
    result = subprocess.run(["git", "ls-remote", "--exit-code", "origin", ref], cwd=ROOT,
                            text=True, capture_output=True)
    if result.returncode == 2 and not result.stdout:
        return None
    assert result.returncode == 0, "remote ref lookup failed"
    rows = [line.split() for line in result.stdout.splitlines()]
    assert len(rows) == 1 and rows[0][1] == ref, "ambiguous remote ref"
    return rows[0][0]


def push(refspec, ref, expected, label, measured=None, lease=None):
    command = ["git", "-c", "push.followTags=false", "push", "--porcelain", "--recurse-submodules=no"]
    if lease is not None:
        command.append("--force-with-lease=" + ref + ":" + lease)
    command += ["origin", refspec]
    attempt = len(list(LOGS.glob("push-" + label + "-*.txt"))) + 1
    log = LOGS / f"push-{label}-{attempt:02}.txt"
    with log.open("xb") as output:
        result = subprocess.run(command, cwd=ROOT, stdout=output, stderr=subprocess.STDOUT)
    observed = remote_tip(ref)
    event = dict(label=label, command=command, returncode=result.returncode,
                 measured_non_thin_pack_bytes=measured, remote_ref=ref, remote_tip=observed,
                 log=log.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(log.read_bytes()).hexdigest())
    with (LOGS / "push-events.jsonl").open("a") as output:
        output.write(json.dumps(event) + "\n")
        output.flush()
    assert result.returncode == 0 and observed == expected, "push failed; inspect its retained log"


def main():
    assert not git("status", "--porcelain"), "push requires a clean repository"
    assert not LOGS.is_symlink(), "publication logs must stay in repository storage"
    LOGS.mkdir(parents=True, exist_ok=True)
    urls = git("remote", "get-url", "--push", "--all", "origin").splitlines()
    assert len(urls) == 1, "publication requires one explicit LinkedSpec remote"
    if "://" in urls[0]:
        url = urlsplit(urls[0]); host, path = url.hostname, url.path.lstrip("/")
    else:
        host, path = urls[0].rsplit("@", 1)[-1].split(":", 1)
    assert host == "github.com" and path.removesuffix(".git") == "rdje/linkedspec", "unexpected push destination"
    subprocess.run(["bash", "tools/verification_receipt.sh", "check-head"], cwd=ROOT,
                   check=True, stdout=subprocess.DEVNULL)
    plan = json.loads((Path(__file__).parent / "push-plan.json").read_bytes())
    assert plan["limit_bytes"] == 1536 * 1024 * 1024, "unexpected conservative upload budget"
    head = git("rev-parse", "HEAD")
    subprocess.run(["git", "merge-base", "--is-ancestor", plan["head"], head],
                   cwd=ROOT, check=True)
    last = plan["batches"][-1]
    if last["target"] != head:
        last["target"] = head
        last["pack_bytes"] = pack_size(last["base"], head)
        assert last["pack_bytes"] < plan["limit_bytes"]
    (LOGS / "push-plan-final.json").write_text(json.dumps(plan, indent=2) + "\n")
    main_ref = "refs/heads/main"
    temporary = "refs/heads/codex/upload-backlog-" + head[:12]
    session_path = LOGS / ("push-session-" + head[:12] + ".json")
    session = dict(head=head, temporary_ref=temporary, initial_main=plan["remote_base"])
    main_tip = remote_tip(main_ref)
    assert main_tip in (plan["remote_base"], head), "main changed outside this publication"
    if session_path.exists():
        assert json.loads(session_path.read_bytes()) == session, "publication session identity differs"
    elif main_tip == head:
        print("push: COMPLETE GitHub main already equals " + head, flush=True)
        return
    else:
        assert remote_tip(temporary) is None, "temporary branch already exists outside this session"
        with session_path.open("x") as output:
            json.dump(session, output)
            output.write("\n")
    if remote_tip(temporary) is None and main_tip != head:
        push(plan["remote_base"] + ":" + temporary, temporary, plan["remote_base"], "seed")
    actual = remote_tip(temporary)
    boundaries = [plan["remote_base"]] + [row["target"] for row in plan["batches"]]
    assert actual in boundaries or main_tip == head, "upload branch changed outside the measured plan"
    first = boundaries.index(actual) if actual in boundaries else len(plan["batches"])
    for number, row in enumerate(plan["batches"]):
        if main_tip == head or number < first:
            continue
        assert git("rev-parse", "HEAD") == head and not git("status", "--porcelain")
        assert remote_tip(main_ref) == plan["remote_base"], "main changed during the upload"
        assert remote_tip(temporary) == row["base"], "upload branch changed between batches"
        subprocess.run(["git", "merge-base", "--is-ancestor", row["base"], row["target"]],
                       cwd=ROOT, check=True)
        measured = pack_size(row["base"], row["target"])
        assert measured < plan["limit_bytes"], "fresh batch estimate exceeds the upload budget"
        print(f"push: starting {number + 1}/{len(plan['batches'])} -> {row['target'][:12]}", flush=True)
        push(row["target"] + ":" + temporary, temporary, row["target"], f"batch-{number + 1:02}", measured)
        print(f"push: verified {number + 1}/{len(plan['batches'])}", flush=True)
    if main_tip != head:
        assert remote_tip(temporary) == head and remote_tip(main_ref) == plan["remote_base"]
        push(head + ":" + main_ref, main_ref, head, "main")
    assert remote_tip(main_ref) == head
    uploaded = remote_tip(temporary)
    if uploaded is not None:
        subprocess.run(["git", "merge-base", "--is-ancestor", uploaded, head], cwd=ROOT, check=True)
        # The lease guards deletion of this session's own temporary ref only.
        push(":" + temporary, temporary, None, "cleanup", lease=uploaded)
    print(f"push: COMPLETE GitHub main equals {head}", flush=True)


if __name__ == "__main__":
    main()
