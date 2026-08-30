# LinkedIn Ghostwriter — n8n package

Drop a rough idea in a Google Sheet. The workflow researches it (Gemini + Google Search), writes the post in your voice, draws a visual with Nano Banana 2 (image 2.0, ~2¢), then either posts to LinkedIn or parks it in the sheet for your approval.

## Files
- `linkedin-ghostwriter-main.n8n.json` — research → write → draw → post/park (18 nodes)
- `linkedin-ghostwriter-approve.n8n.json` — picks up your APPROVED rows and posts them (13 nodes)

## 5-minute setup
1. **Sheet**: create a sheet named `ideas` with header row: `IDEA | STATUS | POST | VISUAL_PROMPT | FIRST_COMMENT | POST_URL | ERROR`
2. **Import** both JSONs into n8n (self-hosted free is fine).
3. **Credentials**: Google Sheets OAuth on every Google Sheets node; LinkedIn OAuth2 on the LinkedIn nodes (LinkedIn dev app with *Share on LinkedIn* + *Sign In with LinkedIn using OpenID Connect*).
4. **CONFIG node** (the only node you edit): paste your spreadsheet ID, Gemini API key, and LinkedIn person ID (open any LinkedIn node — the *Person* dropdown shows your name and stores the ID). Fill `business`, `audience`, `voice`. The full writing doctrine lives in `write_rules` — edit it like a prompt.
5. **Mode**: `APPROVE` (default) parks drafts as READY for you to edit + approve. `AUTO` posts instantly.
6. Activate both workflows. Type an idea, leave STATUS empty.

## How a row moves
`empty/NEW/QUEUED → WRITING → READY (approve mode) → APPROVED → POSTING → POSTED`
Any failure → `ERROR` with the reason in the ERROR column. Set STATUS back to `NEW` (or `APPROVED`) to retry. Rows are locked the moment they're picked up, so nothing ever double-posts.

## Bulletproofing built in
- Structured JSON output from Gemini (responseSchema) — parsing can't break.
- Row locking — no double processing on overlapping polls.
- Error lane on every AI/LinkedIn node — failures land in the sheet, never silently.
- Image optional — if art generation fails, the post still goes out text-only.
- Approve flow regenerates fresh art from the saved prompt; your edited POST text is used as-is.

## Costs
Gemini text on the free tier; one Nano Banana 2 image ≈ $0.02 per post. LinkedIn and n8n self-host: $0.
