#!/usr/bin/env python3
"""Build the website into build/site: the files in website/ plus content.json,
which merges every domain and design problem from Sources/SystemDesignOracle/Content.

Usage: python3 scripts/build_site.py [--serve]   (--serve also starts http://localhost:8000)
"""
import json
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONTENT = ROOT / "Sources" / "SystemDesignOracle" / "Content"
OUT = ROOT / "build" / "site"


def main():
    subprocess.run([sys.executable, str(ROOT / "scripts" / "validate_content.py")], check=True)
    if OUT.exists():
        shutil.rmtree(OUT)
    shutil.copytree(ROOT / "website", OUT)
    content = {
        "domains": [json.loads(f.read_text()) for f in sorted(CONTENT.glob("*.json"))],
        "problems": [json.loads(f.read_text()) for f in sorted((CONTENT / "problems").glob("*.json"))],
    }
    (OUT / "content.json").write_text(json.dumps(content, ensure_ascii=False, separators=(",", ":")))
    (OUT / ".nojekyll").write_text("")
    print(f"Built {OUT.relative_to(ROOT)} ({len(content['domains'])} domains, {len(content['problems'])} problems)")
    if "--serve" in sys.argv:
        print("Serving at http://localhost:8000 (Ctrl-C to stop)")
        subprocess.run([sys.executable, "-m", "http.server", "8000", "-d", str(OUT)])


if __name__ == "__main__":
    main()
