#!/usr/bin/env python3
"""Check every content JSON file against docs/CONTENT-SCHEMA.md, docs/TOPICS.md
and docs/PROBLEMS.md.

Usage: python3 scripts/validate_content.py [domain-file.json ...]
With no arguments, checks every file in Sources/SystemDesignOracle/Content
(and its problems/ folder) and reports anything missing.
Exits non-zero and prints every problem if anything fails.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONTENT = ROOT / "Sources" / "SystemDesignOracle" / "Content"
TOPICS_MD = ROOT / "docs" / "TOPICS.md"
PROBLEMS_MD = ROOT / "docs" / "PROBLEMS.md"
PROBLEMS = CONTENT / "problems"

MINIMUMS = {
    ("overview",): 2,
    ("howItWorks", "components"): 3,
    ("howItWorks", "flow"): 3,
    ("howItWorks", "tradeoffs"): 2,
    ("howItWorks", "numbers"): 3,
    ("expert", "details"): 2,
    ("expert", "failureModes"): 2,
    ("expert", "realSystems"): 2,
    ("expert", "questions"): 2,
    ("related",): 2,
}
ITEM_KEYS = {
    ("howItWorks", "components"): {"name", "role"},
    ("howItWorks", "tradeoffs"): {"choice", "pro", "con"},
    ("howItWorks", "numbers"): {"metric", "value"},
    ("expert", "failureModes"): {"name", "description"},
    ("expert", "realSystems"): {"name", "note"},
    ("expert", "questions"): {"q", "a"},
}


def planned_topics():
    domains, current = {}, None
    for line in TOPICS_MD.read_text().splitlines():
        if m := re.match(r"## (\S+) — ", line):
            current = m.group(1)
            domains[current] = []
        elif (m := re.match(r"- (\S+) — ", line)) and current:
            domains[current].append(m.group(1))
    return domains


PROBLEM_MINIMUMS = {
    ("overview",): 2,
    ("requirements", "functional"): 3,
    ("requirements", "nonFunctional"): 3,
    ("requirements", "estimates"): 3,
    ("stages",): 4,
    ("tradeoffs",): 3,
    ("expert", "failureModes"): 3,
    ("expert", "realSystems"): 2,
    ("expert", "questions"): 3,
    ("related",): 3,
}
PROBLEM_ITEM_KEYS = {
    ("requirements", "estimates"): {"metric", "value"},
    ("stages",): {"name", "summary", "points", "deepDive"},
    ("tradeoffs",): {"choice", "pro", "con"},
    **{k: v for k, v in ITEM_KEYS.items() if k[0] == "expert"},
}


def planned_problems():
    out = {}
    for line in PROBLEMS_MD.read_text().splitlines():
        if m := re.match(r"- (\S+) — (\S+) — (.+)$", line):
            out[m.group(1)] = (m.group(2), m.group(3).strip())
    return out


def get(obj, path):
    for key in path:
        if not isinstance(obj, dict) or key not in obj:
            return None
        obj = obj[key]
    return obj


def check_lists(t, where, minimums, item_keys):
    errors = []
    for p, n in minimums.items():
        v = get(t, p)
        if not isinstance(v, list) or len(v) < n:
            errors.append(f"{where}: {'.'.join(p)} needs >= {n} items")
            continue
        keys = item_keys.get(p)
        for item in v:
            if keys:
                if not isinstance(item, dict) or not keys <= set(item):
                    errors.append(f"{where}: {'.'.join(p)} item needs {sorted(keys)}")
            elif not isinstance(item, str) or not item.strip():
                errors.append(f"{where}: {'.'.join(p)} item must be a non-empty string")
    return errors


def check_diagram(t, where):
    errors = []
    steps = get(t, ("diagram", "steps"))
    if not isinstance(steps, list) or not 3 <= len(steps) <= 7:
        errors.append(f"{where}: diagram.steps must have 3-7 items")
    else:
        for s in steps:
            if not {"label", "detail"} <= set(s):
                errors.append(f"{where}: diagram step missing label/detail")
    if not get(t, ("diagram", "caption")):
        errors.append(f"{where}: diagram.caption missing")
    return errors


def check_related(t, where, all_ids):
    errors = []
    for r in t.get("related", []):
        if r not in all_ids:
            errors.append(f"{where}: related '{r}' is not a planned topic id")
        if r == t.get("id"):
            errors.append(f"{where}: related to itself")
    return errors


def check_problem(path, planned, all_ids):
    try:
        t = json.loads(path.read_text())
    except json.JSONDecodeError as e:
        return [f"{path.name}: invalid JSON: {e}"]
    where = f"problems/{path.name}"
    errors = []
    pid = t.get("id")
    if pid not in planned:
        return [f"{where}: id '{pid}' not in PROBLEMS.md"]
    if path.stem != pid:
        errors.append(f"{where}: file name must be {pid}.json")
    domain, prompt = planned[pid]
    if t.get("domain") != domain:
        errors.append(f"{where}: domain must be '{domain}'")
    if t.get("prompt", "").strip() != prompt:
        errors.append(f"{where}: prompt must match PROBLEMS.md exactly")
    for key in ("title", "gist"):
        if not isinstance(t.get(key), str) or not t[key].strip():
            errors.append(f"{where}: missing '{key}'")
    if len(t.get("gist", "").split()) > 35:
        errors.append(f"{where}: gist over 35 words")
    errors += check_diagram(t, where)
    errors += check_lists(t, where, PROBLEM_MINIMUMS, PROBLEM_ITEM_KEYS)
    for st in t.get("stages", []):
        if isinstance(st, dict):
            if len(st.get("points", [])) < 3:
                errors.append(f"{where}: stage '{st.get('name')}' needs >= 3 points")
            if len(st.get("deepDive", [])) < 1:
                errors.append(f"{where}: stage '{st.get('name')}' needs >= 1 deepDive")
    errors += check_related(t, where, all_ids)
    return errors


def check_file(path, planned, all_ids):
    errors = []
    try:
        domain = json.loads(path.read_text())
    except json.JSONDecodeError as e:
        return [f"{path.name}: invalid JSON: {e}"]
    for key in ("id", "name", "symbol", "summary", "topics"):
        if key not in domain:
            errors.append(f"{path.name}: missing domain key '{key}'")
    did = domain.get("id")
    if did not in planned:
        errors.append(f"{path.name}: domain id '{did}' not in TOPICS.md")
        return errors
    ids = [t.get("id") for t in domain.get("topics", [])]
    if ids != planned[did]:
        errors.append(f"{path.name}: topic ids {ids} != planned {planned[did]}")
    for t in domain.get("topics", []):
        where = f"{path.name}:{t.get('id')}"
        for key in ("title", "gist"):
            if not isinstance(t.get(key), str) or not t[key].strip():
                errors.append(f"{where}: missing '{key}'")
        if len(t.get("gist", "").split()) > 35:
            errors.append(f"{where}: gist over 35 words")
        errors += check_diagram(t, where)
        errors += check_lists(t, where, MINIMUMS, ITEM_KEYS)
        errors += check_related(t, where, all_ids)
    return errors


def main():
    planned = planned_topics()
    all_ids = {i for ids in planned.values() for i in ids}
    problems = planned_problems()
    args = [Path(a).resolve() for a in sys.argv[1:]]
    files = args or sorted(CONTENT.glob("*.json")) + sorted(PROBLEMS.glob("*.json"))
    errors = []
    for f in files:
        if f.parent.name == "problems":
            errors += check_problem(f, problems, all_ids)
        else:
            errors += check_file(f, planned, all_ids)
    if not args:
        found = {json.loads(f.read_text()).get("id") for f in CONTENT.glob("*.json")}
        for missing in sorted(set(planned) - found):
            errors.append(f"missing domain file for '{missing}'")
        found = {f.stem for f in PROBLEMS.glob("*.json")}
        for missing in sorted(set(problems) - found):
            errors.append(f"missing problem file for '{missing}'")
    for e in errors:
        print(e)
    print(f"{len(files)} file(s) checked, {len(errors)} problem(s)")
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
