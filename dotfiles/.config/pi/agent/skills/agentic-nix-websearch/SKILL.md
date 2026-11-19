---
name: agentic-nix-websearch
description: Search the web and read webpages using Nix-run CLI tools (ddgr, lynx, jq). Trigger when needing current documentation, error lookups, library APIs, or facts outside local files.
---

# Agentic Websearch

Use a strict three-stage pipeline (**Search -> Distill -> Slice**) to keep token usage minimal and avoid dumping raw HTML into context.

## Hard Rules

- **NEVER install tools.** Run `ddgr`, `lynx`, and `jq` via `nix run`.
- **NEVER omit `--np --json` when calling `ddgr`.** Interactive mode hangs non-interactive terminals.
- **NEVER dump raw HTML or full webpages to stdout.** Always distill to `/tmp/web_page.txt` first, then inspect selectively.
- **Cap output.** Pipe searches through `head` to prevent context blowups.

## 1. Search (`ddgr` + `jq`)

Query DuckDuckGo and strip results down to title, URL, and abstract:

```bash
nix run nixpkgs#ddgr -- --np --json -n 5 "<query>" \
  | nix run nixpkgs#jq -- '[.[] | {title, url, abstract}]'
```

- For recent releases, bugs, or news, add a time filter before `<query>`: `-t m` (past month) or `-t y` (past year).
- Read the returned abstracts first. Only proceed to Stage 2 if the snippets do not answer the question.

## 2. Fetch & Distill (`lynx`)

Fetch the target URL once, strip HTML boilerplate, and save plain text to a temp file while checking its line count:

```bash
timeout 20 nix run nixpkgs#lynx -- -dump -nolist -width=120 "<url>" > /tmp/web_page.txt && wc -l /tmp/web_page.txt
```

- **Raw text/docs shortcut:** For plain text, JSON, or raw Markdown URLs (e.g., `raw.githubusercontent.com`), use `curl -fsSL --max-time 20 "<url>" > /tmp/web_page.txt` instead of `lynx`.
- **Bail-out rule:** If `/tmp/web_page.txt` has fewer than 15 lines or shows a CAPTCHA, 403 error, or "Enable JavaScript" wall, do not retry the same URL—move to the next search result.

## 3. Progressive Inspection (Grep -> Slice)

1. **Grep first** for specific keywords with line numbers and surrounding context:

```bash
grep -inE -C 3 "<term1|term2>" /tmp/web_page.txt | head -n 60
```

2. **Expand targeted slices** using the line numbers from `grep -n`:

```bash
sed -n '120,210p' /tmp/web_page.txt
```

3. **Fallback if grep misses** (due to different phrasing): read from the top in bounded chunks rather than printing the entire file:

```bash
sed -n '1,120p' /tmp/web_page.txt
```
