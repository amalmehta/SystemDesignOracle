#!/usr/bin/env python3
"""Build the website into build/site: the files in website/ plus content.json,
which merges every domain and design problem from Sources/SystemDesignOracle/Content.

Usage: python3 scripts/build_site.py [--serve]
--serve also previews it at http://localhost:8000 (or the next free port).
"""
import errno
import functools
import json
import shutil
import socket
import subprocess
import sys
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONTENT = ROOT / "Sources" / "SystemDesignOracle" / "Content"
OUT = ROOT / "build" / "site"


def build():
    if subprocess.run([sys.executable, str(ROOT / "scripts" / "validate_content.py")]).returncode:
        sys.exit("Content check failed — fix the problems above, then build again.")
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


class QuietHandler(SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


def in_use(port):
    """True if anything answers on localhost:port, over IPv4 or IPv6."""
    try:
        socket.create_connection(("localhost", port), timeout=0.3).close()
        return True
    except OSError:
        return False


def serve(first_port=8000, tries=20):
    handler = functools.partial(QuietHandler, directory=str(OUT))
    for port in range(first_port, first_port + tries):
        if in_use(port):
            continue
        try:
            server = ThreadingHTTPServer(("localhost", port), handler)
            break
        except OSError as e:
            if e.errno != errno.EADDRINUSE:
                raise
    else:
        sys.exit(f"Ports {first_port}–{first_port + tries - 1} are all in use.")
    note = "" if port == first_port else f" (port {first_port} was busy)"
    print(f"Serving at http://localhost:{port}{note} — press Ctrl-C to stop")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")
    finally:
        server.server_close()


if __name__ == "__main__":
    build()
    if "--serve" in sys.argv:
        serve()
