"""Strict, bounded scope admission for maintained canonical references."""
from collections import Counter
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess

ROOT = Path(__file__).resolve().parent.parent
INDEX = "doctrine/readme_stability/reference-scope/index.jsonl"
AUTHORITY = "docs/decisions/0139-approved-archive-reference-contracts.md"
OWNER = re.compile(r"[A-Z][A-Z0-9-]*(?:\.[0-9]+)+\Z")
PAGE_ROWS = 128
FILE_BYTES = 65536


def require(test, message):
    if not test:
        raise ValueError(message)


def canonical(value):
    return json.dumps(value, sort_keys=True, ensure_ascii=False, separators=(",", ":")).encode() + b"\n"


def path(value):
    require(isinstance(value, str) and value and "\0" not in value and "\\" not in value,
            "invalid scope path")
    parsed = PurePosixPath(value)
    require(not parsed.is_absolute() and str(parsed) == value
            and not any(part in (".", "..", ".git") for part in parsed.parts), "unsafe scope path")
    return value


def strict_json(raw):
    def pairs(items):
        result = {}
        for key, value in items:
            require(key not in result, "duplicate scope JSON key")
            result[key] = value
        return result
    return json.loads(raw, object_pairs_hook=pairs,
                      parse_constant=lambda value: (_ for _ in ()).throw(ValueError("nonfinite scope JSON")))


def lines(raw):
    require(isinstance(raw, bytes) and len(raw) <= FILE_BYTES and raw.endswith(b"\n"), "scope file byte/newline bound")
    rows = raw.splitlines()
    require(rows and len(rows) <= 512, "scope file row bound")
    result = []
    for raw_line in rows:
        row = strict_json(raw_line)
        require(isinstance(row, dict) and canonical(row) == raw_line + b"\n", "noncanonical scope row")
        result.append(row)
    return result


def keys(row, expected):
    require(isinstance(row, dict) and set(row) == set(expected), "scope row schema mismatch")


def integer(value):
    return type(value) is int and value >= 0


def count_lines(raw):
    return raw.count(b"\n") + (1 if raw and not raw.endswith(b"\n") else 0)


def pattern(pattern_, value):
    # The same path-glob language as the routing checker, including zero-depth **/.
    expression = ""
    index = 0
    while index < len(pattern_):
        if pattern_.startswith("**/", index):
            expression += "(?:.*/)?"
            index += 3
        elif pattern_.startswith("**", index):
            expression += ".*"
            index += 2
        elif pattern_[index] == "*":
            expression += "[^/]*"
            index += 1
        elif pattern_[index] == "?":
            expression += "[^/]"
            index += 1
        else:
            expression += re.escape(pattern_[index])
            index += 1
    return re.fullmatch(expression, value) is not None


class Snapshot:
    def __init__(self):
        self.before = self.git("ls-files", "--stage", "-z")
        self.index = {}
        for row in self.before.split(b"\0"):
            if row:
                header, name = row.split(b"\t", 1)
                mode, blob, stage = header.decode().split()
                require(stage == "0", "unmerged scope input")
                self.index[name.decode()] = (mode, blob)
        self.staged = bool(self.git("diff", "--cached", "--name-only", "-z"))
        self.paths = set(self.index)
        if not self.staged:
            self.paths.update(self.git("ls-files", "--others", "--exclude-standard", "-z").decode().split("\0"))
            self.paths.discard("")
            self.paths = {p for p in self.paths if (ROOT / p).exists() or (ROOT / p).is_symlink()}
        self.base = self.git("rev-parse", "HEAD").decode().strip()
        self.batch = None
        self.cache = {}
        self.cached_bytes = 0
        self.owner_counts = None

    @staticmethod
    def git(*args, allow_missing=False):
        result = subprocess.run(["git", "-C", str(ROOT), *args], capture_output=True)
        if allow_missing and result.returncode:
            return None
        require(result.returncode == 0, "scope Git read failed: " + result.stderr.decode(errors="replace"))
        return result.stdout

    def read(self, name):
        path(name)
        require(name in self.paths, "scope input is missing: " + name)
        cursor = ROOT
        for part in PurePosixPath(name).parts:
            cursor /= part
            require(not cursor.is_symlink(), "scope input is symbolic: " + name)
        if name in self.cache:
            return self.cache[name]
        if self.staged:
            mode, blob = self.index[name]
            require(mode in ("100644", "100755"), "scope input is not a regular tracked file")
            if self.batch is None:
                self.batch = subprocess.Popen(["git", "-C", str(ROOT), "cat-file", "--batch"],
                                              stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                              stderr=subprocess.PIPE)
            self.batch.stdin.write(blob.encode() + b"\n")
            self.batch.stdin.flush()
            header = self.batch.stdout.readline().decode().strip().split()
            require(len(header) == 3 and header[:2] == [blob, "blob"], "invalid scope blob response")
            remaining = int(header[2])
            chunks = []
            while remaining:
                chunk = self.batch.stdout.read(remaining)
                require(bool(chunk), "truncated scope blob")
                chunks.append(chunk)
                remaining -= len(chunk)
            require(self.batch.stdout.read(1) == b"\n", "invalid scope blob terminator")
            raw = b"".join(chunks)
        else:
            raw = (ROOT / name).read_bytes()
        if self.cached_bytes + len(raw) <= 32 * 1024 * 1024:
            self.cache[name] = raw
            self.cached_bytes += len(raw)
        return raw

    def head(self, name):
        path(name)
        return self.git("show", "HEAD:" + name, allow_missing=True)

    def selected_owner(self):
        if self.staged:
            result = subprocess.run(["perl", "tools/check_task_verification_fields.pl", "--owner"],
                                    cwd=ROOT, capture_output=True)
            require(result.returncode == 0, "scope owner selection failed: " + result.stderr.decode(errors="replace"))
            return result.stdout.decode().strip()
        match = re.search(rb"^- active_work_unit: " + bytes([96]) + rb"([^" + bytes([96]) + rb"]+)",
                          self.read("MEMORY.md"), re.M)
        return match[1].decode() if match else None

    def owner_exists(self, owner):
        if self.owner_counts is None:
            immutable = set()
            for name in sorted(self.paths):
                if name.startswith("docs/tasks/") and name.endswith(".index.jsonl"):
                    for raw in self.read(name).splitlines():
                        row = strict_json(raw)
                        if row.get("type") == "task_tree_part" and row.get("mutable") is False:
                            immutable.add(row["path"])
            self.owner_counts = Counter()
            for name in sorted(self.paths):
                if name.startswith("docs/tasks/") and name.endswith(".md") and name not in immutable:
                    self.owner_counts.update(re.findall(rb"^- ID: " + bytes([96]) + rb"([^" + bytes([96]) +
                                                       rb"\n]+)" + bytes([96]) + rb"\n",
                                                       self.read(name), re.M))
        return self.owner_counts[owner.encode()] == 1

    def finish(self):
        if self.batch:
            self.batch.stdin.close()
            self.batch.stdin = None
            extra, error = self.batch.communicate()
            require(self.batch.returncode == 0 and not extra,
                    "scope blob reader failed: " + error.decode(errors="replace"))
            self.batch = None
        require(self.git("ls-files", "--stage", "-z") == self.before,
                "index changed during maintained-reference verification")

    def abort(self):
        if self.batch:
            self.batch.kill()
            self.batch.communicate()
            self.batch = None


def surfaces(snapshot):
    rows = [strict_json(line) for line in snapshot.read("doctrine/readme_stability/routes.jsonl").splitlines()]
    result = {r["id"]: r for r in rows if r.get("type") == "surface" and r.get("control") == "scoped_reference"}
    require(result, "no maintained-reference scope is declared")
    for value in result.values():
        require(set(value["limits"]) == {"max_lines_per_file", "max_bytes_per_file"},
                "maintained-reference per-file controls are incomplete")
        require(all(type(x) is int and x > 0 for x in value["limits"].values()),
                "maintained-reference bounds must be JSON integers")
    return result


def members(snapshot, declared):
    result = {}
    for role, surface in sorted(declared.items()):
        selected = set()
        for glob in surface["members"]:
            matches = {name for name in snapshot.paths if pattern(glob, name)}
            require(matches, "scope member pattern has no input: " + glob)
            selected.update(matches)
        for name in sorted(selected):
            raw = snapshot.read(name)
            require(b"\0" not in raw, "maintained reference is not text: " + name)
            item = {"type": "member", "path": name, "sha256": hashlib.sha256(raw).hexdigest(),
                    "bytes": len(raw), "lines": count_lines(raw)}
            bounds = surface["limits"]
            require(item["bytes"] <= bounds["max_bytes_per_file"] and item["lines"] <= bounds["max_lines_per_file"],
                    "maintained reference exceeds per-file bound: " + name)
            result[role, name] = item
    return result


def load(read, index=INDEX):
    root_rows = lines(read(index))
    root = root_rows.pop(0)
    keys(root, ("type", "schema_version", "authority", "baseline_commit", "update_owner",
                "surfaces", "page_count", "member_count"))
    require(root["type"] == "reference_scope_index" and type(root["schema_version"]) is int
            and root["schema_version"] == 1 and root["authority"] == AUTHORITY, "scope index contract mismatch")
    require(isinstance(root["baseline_commit"], str) and isinstance(root["update_owner"], str)
            and re.fullmatch(r"[0-9a-f]{40}", root["baseline_commit"]) and OWNER.fullmatch(root["update_owner"]),
            "scope provenance mismatch")
    require(isinstance(root["surfaces"], list) and root["surfaces"]
            and all(isinstance(role, str) and re.fullmatch(r"[a-z][a-z0-9_]*", role)
                    for role in root["surfaces"]), "invalid scope surface set")
    require(all(integer(root[x]) for x in ("page_count", "member_count"))
            and root["page_count"] == len(root_rows) and root_rows, "scope index counts mismatch")
    entries, page_paths, ordinals = {}, [], Counter()
    for descriptor in root_rows:
        keys(descriptor, ("type", "surface", "path", "sha256", "bytes", "members"))
        role, name = descriptor["surface"], path(descriptor["path"])
        require(descriptor["type"] == "scope_page" and isinstance(role, str) and role in root["surfaces"]
                and name == f"doctrine/readme_stability/reference-scope/{role}-{ordinals[role]:03d}.jsonl",
                "scope page identity mismatch")
        ordinals[role] += 1
        require(name not in page_paths, "duplicate scope page")
        page_paths.append(name)
        raw = read(name)
        require(integer(descriptor["bytes"]) and integer(descriptor["members"])
                and len(raw) == descriptor["bytes"] and hashlib.sha256(raw).hexdigest() == descriptor["sha256"],
                "scope page digest/count mismatch")
        rows = lines(raw)
        header = rows.pop(0)
        keys(header, ("type", "schema_version", "surface", "member_count"))
        require(header == {"type": "reference_scope_page", "schema_version": 1, "surface": role,
                           "member_count": len(rows)} and type(header["schema_version"]) is int
                and integer(header["member_count"]) and 0 < len(rows) <= PAGE_ROWS
                and len(rows) == descriptor["members"], "scope page schema/count mismatch")
        for item in rows:
            keys(item, ("type", "path", "sha256", "bytes", "lines", "owner"))
            key = role, path(item["path"])
            require(item["type"] == "member" and key not in entries
                    and isinstance(item["sha256"], str) and re.fullmatch(r"[0-9a-f]{64}", item["sha256"])
                    and integer(item["bytes"]) and integer(item["lines"])
                    and isinstance(item["owner"], str) and OWNER.fullmatch(item["owner"]),
                    "scope member schema/identity mismatch")
            entries[key] = item
    require(root["member_count"] == len(entries) and root["surfaces"] == sorted(set(root["surfaces"])),
            "scope root member/surface count mismatch")
    require(list(entries) == sorted(entries), "scope members are not canonically ordered")
    return root, entries, page_paths


def previous(snapshot):
    if snapshot.head(INDEX) is None:
        return None, {}
    root, entries, _ = load(snapshot.head)
    return root, entries


def verify(snapshot):
    declared = surfaces(snapshot)
    root, entries, pages = load(snapshot.read)
    actual = members(snapshot, declared)
    require(root["surfaces"] == sorted(declared) and set(entries) == set(actual),
            "maintained reference is missing or unindexed")
    require(snapshot.owner_exists(root["update_owner"]), "scope update owner is not current and unique")
    for key, item in entries.items():
        require({k: v for k, v in item.items() if k != "owner"} == actual[key],
                "stale maintained-reference scope: " + key[1])
        require(snapshot.owner_exists(item["owner"]), "scope member owner is not current and unique")
    expected_paths = set(pages) | {INDEX}
    present = {p for p in snapshot.paths if p.startswith("doctrine/readme_stability/reference-scope/")}
    require(present == expected_paths, "unknown or missing reference-scope store member")
    prior_root, old = previous(snapshot)
    changed = {key for key in entries if key not in old or entries[key] != old[key]}
    require(not (set(old) - set(entries)), "scope retirement requires an explicit preservation migration")
    if changed:
        selected = snapshot.selected_owner()
        require(selected and OWNER.fullmatch(selected) and root["update_owner"] == selected,
                "changed scope is not owned by the selected leaf")
        for key in changed:
            require(entries[key]["owner"] == selected, "changed member has a foreign scope owner")
            require(key not in old or entries[key]["sha256"] != old[key]["sha256"],
                    "unchanged reference provenance was reassigned")
    if prior_root is None:
        require(root["baseline_commit"] == snapshot.base, "initial scope adoption boundary differs from HEAD")
        text = snapshot.read(AUTHORITY).decode()
        tick = chr(96)
        require(len(re.findall(r"^- Status: accepted(?:[ ;].*)?$", text, re.M)) == 1
                and f"- Scope adoption owner: {tick}{root['update_owner']}{tick}" in text,
                "initial maintained scope lacks accepted adoption authority")
    else:
        require(root["baseline_commit"] == prior_root["baseline_commit"], "scope adoption boundary changed")
        if not changed:
            require(root["update_owner"] == prior_root["update_owner"], "unchanged scope provenance was reassigned")
    return len(entries), len(pages)


def build(snapshot, owner):
    require(OWNER.fullmatch(owner) and owner == snapshot.selected_owner() and snapshot.owner_exists(owner),
            "scope update requires its selected unique owning leaf")
    declared = surfaces(snapshot)
    actual = members(snapshot, declared)
    prior_root, old = previous(snapshot)
    require(not (set(old) - set(actual)), "scope retirement requires an explicit preservation migration")
    entries = {}
    for key, item in actual.items():
        previous_item = old.get(key)
        entries[key] = dict(item, owner=previous_item["owner"] if previous_item
                            and previous_item["sha256"] == item["sha256"] else owner)
    output, descriptors = {}, []
    for role in sorted(declared):
        rows = [item for key, item in entries.items() if key[0] == role]
        groups, group = [], []
        for row in rows:
            prospective = group + [row]
            header = {"type": "reference_scope_page", "schema_version": 1,
                      "surface": role, "member_count": len(prospective)}
            if group and (len(prospective) > PAGE_ROWS or len(canonical(header)) +
                          sum(len(canonical(x)) for x in prospective) > FILE_BYTES):
                groups.append(group)
                group = []
            group.append(row)
        if group:
            groups.append(group)
        for ordinal, page in enumerate(groups):
            name = f"doctrine/readme_stability/reference-scope/{role}-{ordinal:03d}.jsonl"
            raw = canonical({"type": "reference_scope_page", "schema_version": 1,
                             "surface": role, "member_count": len(page)}) + b"".join(canonical(x) for x in page)
            require(len(raw) <= FILE_BYTES, "scope page cannot fit one member")
            output[name] = raw
            descriptors.append({"type": "scope_page", "surface": role, "path": name,
                                "sha256": hashlib.sha256(raw).hexdigest(), "bytes": len(raw), "members": len(page)})
    changed = prior_root is None or entries != old
    root = {"type": "reference_scope_index", "schema_version": 1, "authority": AUTHORITY,
            "baseline_commit": prior_root["baseline_commit"] if prior_root else snapshot.base,
            "update_owner": owner if changed else prior_root["update_owner"],
            "surfaces": sorted(declared), "page_count": len(descriptors), "member_count": len(entries)}
    output[INDEX] = canonical(root) + b"".join(canonical(row) for row in descriptors)
    require(len(output[INDEX]) <= FILE_BYTES and len(descriptors) < 512, "scope root exceeds its bound")
    return output
