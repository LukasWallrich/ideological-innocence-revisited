#!/usr/bin/env python3
"""Build the GitHub Pages site from the single canonical manuscript.

Reads the committed, locally-rendered manuscript (manuscript/manuscript.html),
injects the "AI-generated / not yet validated" warning banner at the top of the
page, and writes the result to <out>/index.html (default: _site/index.html).

There is deliberately NO second committed copy of the HTML: the published page is
derived from the one source file at deploy time, so it cannot drift. Run locally to
preview, or let .github/workflows/deploy-pages.yml run it in CI on push.

Usage:
    python3 scripts/build_pages.py [--src manuscript/manuscript.html] [--out _site]
"""
from __future__ import annotations

import argparse
import pathlib
import re
import sys

REPO_URL = "https://github.com/LukasWallrich/ideological-innocence-revisited"

BANNER = f"""
<div style="max-width:100%;box-sizing:border-box;margin:0;padding:14px 18px;background:#7f1d1d;color:#fff;font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;font-size:15px;line-height:1.5;border-bottom:3px solid #450a0a;">
  <div style="max-width:900px;margin:0 auto;">
    <strong style="font-size:16px;">&#9888;&#65039; AI-generated and not yet validated.</strong>
    This manuscript was produced end-to-end by an AI-agent workflow (Anthropic's Claude) and has
    <strong>not been validated by a human, peer-reviewed, or independently replicated by a person</strong>.
    Every number, claim, and interpretation is <strong>provisional and unverified</strong>. Please do not
    cite it or rely on it as established science. It is shared openly for transparency and to invite scrutiny.
    See the <a href="{REPO_URL}" style="color:#fecaca;text-decoration:underline;">repository README</a>
    and the manuscript's own AI-assistance statement for detail.
  </div>
</div>
"""


def build(src: pathlib.Path, out_dir: pathlib.Path) -> pathlib.Path:
    html = src.read_text(encoding="utf-8")
    m = re.search(r"<body[^>]*>", html)
    if not m:
        sys.exit(f"error: no <body> tag found in {src}")
    injected = html[: m.end()] + BANNER + html[m.end():]

    out_dir.mkdir(parents=True, exist_ok=True)
    out_file = out_dir / "index.html"
    out_file.write_text(injected, encoding="utf-8")
    # .nojekyll stops GitHub Pages from running the file through Jekyll.
    (out_dir / ".nojekyll").write_text("", encoding="utf-8")
    return out_file


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--src", default="manuscript/manuscript.html", type=pathlib.Path)
    ap.add_argument("--out", default="_site", type=pathlib.Path)
    args = ap.parse_args()
    if not args.src.exists():
        sys.exit(
            f"error: {args.src} not found. Render it first with "
            "`quarto render manuscript/manuscript.qmd`."
        )
    out_file = build(args.src, args.out)
    print(f"wrote {out_file} ({out_file.stat().st_size:,} bytes) with warning banner")


if __name__ == "__main__":
    main()
