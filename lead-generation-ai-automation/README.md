# AI Lead Machine (n8n workflow)

A free, production-ready n8n workflow that finds real businesses for any niche + city,
enriches them, and lets an AI agent (Google Gemini) qualify and score each one against
**your** criteria — only the qualified leads land in your Google Sheet, and every lead
(accepted or rejected, with its reason) is kept in a log tab so nothing gets lost.

```
Form (your inputs) → Apify Google Maps actor → normalize
→ per lead: Firecrawl enrich (if website) → Gemini AI agent scores & judges
→ qualified? → "qualified" tab   |   every lead → "log" tab
```

## What the form asks

| Field | Example |
|---|---|
| Business / Client Type | gyms, dental clinics, real-estate agents |
| Number of Leads | 50 (capped at 100 per run) |
| City | Karachi |
| Qualification Criteria / Special Requirements | "rating 3.8–4.5, complaints about slow response are a plus" |

## Setup (5 minutes)

1. **Import** `lead-machine.n8n.json` in n8n (Settings → Import Workflow, or paste).
   Works on n8n Cloud free trial, the $20 plan, or free self-hosted.
2. **Replace the two placeholders** in the HTTP nodes:
   - `APIFY_TOKEN_PLACEHOLDER` → your Apify API token (free credits on signup; actor used: `compass/crawler-google-places`).
   - `FIRECRAWL_TOKEN_PLACEHOLDER` → your Firecrawl API key (free credits on signup).
3. **Connect credentials** on the two nodes that ask:
   - *Gemini Model* → Google Gemini(PaLM) API credential (Gemini has a free tier).
   - *Sheet — qualified* / *Sheet — log* → your Google account.
4. **Create a Google Sheet** with two tabs named exactly `qualified` and `log`,
   paste this header row in each, and put the sheet ID into both Sheets nodes
   (replace `YOUR_GOOGLE_SHEET_ID` — it's the long ID in the sheet URL):
   - `qualified`: `name  city  phone  website  rating  score  hook  reason  date`
   - `log`: `name  city  score  status  reason  date`
5. **Activate** the workflow and open the form URL it gives you. Fill it, submit, done.

## How the agent decides (and how to tune it)

The scoring rubric lives in the **Qualify Agent** node's system message:
website +15, 20+ reviews +15, rating 3.8–4.5 +20, recent activity +10, real pain in
reviews/page +20, public contact +10, fresh content +10. **70+ = qualified.**
Sparse data never auto-rejects (it caps at 60 and says what's missing), and every
verdict must cite evidence — that's what keeps it from accepting or dropping everyone.
Change weights, the 70 threshold, or add rules in that one text box; per-run overrides
go in the form's criteria field.

## Cost to start

Every service has a free tier: n8n (self-host or trial), Apify credits, Firecrawl
credits, Gemini API. Upgrade only after the sheet proves value.

## Rules of the road

Public data only, respect each platform's ToS, and if you contact leads afterwards:
personalise from the `hook` column, max 3 touches, honour opt-outs. This machine earns
introductions — it's not a spam cannon.
