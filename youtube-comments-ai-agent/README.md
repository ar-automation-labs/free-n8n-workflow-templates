# YouTube Comment AI Agent (n8n)

An AI agent that replies to your YouTube comments — **in your voice, not a canned bot.**

Built with n8n + the free Gemini API + the YouTube Data API. It watches your channel, reads new comments, and:

- ✅ Replies to genuine questions and praise — **in your tone**
- ✅ Skips spam, hate, self-promotion and your **own comments** — automatically
- ✅ Flags risky comments (complaints, pricing/lead requests) for **your approval**
- ✅ Answers "how do I get this?" comments with **your workflow link** (lead magnet)
- ✅ Logs every decision to **Google Sheets**

---

## Two workflows (import both)

| File | What it does | Runs |
|---|---|---|
| `YouTube-Comment-AI-Agent.json` | Finds new comments → AI decides → replies / flags / skips → logs | every **15 min** |
| `Post-Approved-Replies.json` | Posts any reply you marked `APPROVED` in the Approvals sheet | every **5 min** |

The two-workflow split means the AI **never posts without you** on risky comments, and you get a clean approve-then-post loop.

---

## What you need (all free to start)

1. **n8n** — cloud (free trial) or self-hosted
2. **Google Cloud project** with the **YouTube Data API v3** enabled + OAuth consent screen
3. **Gemini API key** — free at [Google AI Studio](https://aistudio.google.com/apikey)
4. **A Google Sheet** with two tabs: `Log` and `Approvals`

---

## Setup — 5 minutes

### Step 1 — Create the Google Sheet
Make a spreadsheet and name two tabs exactly: **`Log`** and **`Approvals`**.
Add this header row to **both** tabs:

```
timestamp | author | comment | reply | status | commentId | videoId
```

### Step 2 — Create 3 credentials in n8n
| Credential type | Details |
|---|---|
| **YouTube OAuth2 API** | Connect your Google account. **Important:** add the scope `https://www.googleapis.com/auth/youtube.force-ssl` (this is what lets it read *and* post comments). |
| **Google Sheets OAuth2** | Connect the same Google account. |
| **Header Auth** | Name = `x-goog-api-key`, Value = your Gemini API key. |

> ⚠️ **If posting replies fails with `403 forbidden / insufficient permissions`:** Google remembered an old consent without the `force-ssl` scope. Fix: go to **myaccount.google.com/permissions**, remove the app's access, then reconnect the credential in n8n — Google will ask again with the full scope.

### Step 3 — Import the workflows
n8n → **Workflows → ⋯ → Import from File** → pick each `.json`. Accept any node-upgrade prompt n8n shows.

### Step 4 — Edit the `Business Setup` node (one place)
Open **`Business Setup`** in the main workflow and check:

```
CHANNEL_ID      = "UCoKHIVHitBuBu5m0M_Ykdsw"   ← your channel ID (prefilled — verify it's yours)
MY_CHANNEL_ID   = "UCoKHIVHitBuBu5m0M_Ykdsw"   ← used to skip your own comments
MODE            = "auto"        ← "auto" posts safe replies; "approve" drafts everything, posts nothing
LOOKBACK_HOURS  = 12            ← only process comments newer than this
GEMINI_MODEL    = "gemini-2.5-flash"
```

- **How to find your channel ID:** Studio → Settings → Channel → "Advanced settings", or paste your channel URL into any "channel ID" lookup. It starts with `UC`.
- The **system prompt** (ARIA's identity, your voice, the rules) is in the same node — edit it there.

### Step 5 — Select the documents
On every **Google Sheets** node, pick your spreadsheet (and the `Log` / `Approvals` tab). On every **HTTP Request** node that touches YouTube, pick your YouTube credential; on the **AI Agent (ARIA)** node, pick your Header Auth (Gemini) credential.

### Step 6 — Test
1. Open the main workflow → click the **Schedule Trigger** node → **Execute node** (runs the whole flow once).
2. Watch the **Executions** tab. Leave a test comment on your own video, run again, and check the `Log` sheet.
3. When you're happy, toggle the workflow **Active**.

---

## How the approve loop works

1. The main workflow drafts replies. Safe ones post automatically (in `MODE: auto`).
2. Risky ones land in the **`Approvals`** sheet with status **`NEW`** and the drafted reply.
3. You read them, edit the reply if you want, and change status to **`APPROVED`**.
4. **`Post-Approved-Replies`** finds `APPROVED` rows and posts them, then marks them **`POSTED`**.

> If a row re-posts instead of updating to `POSTED`, open the **Mark POSTED** node and confirm **Column to Match On = `commentId`**.

---

## Good to know

- **Quota:** the YouTube Data API gives ~10,000 units/day; a reply costs 50 units (~200 replies/day — plenty). Listing comments costs 1 unit. Gemini has a free tier.
- **Dedup:** processed comment IDs are stored in n8n's workflow static data, so nothing is ever replied to twice (even across restarts).
- **First run:** only comments from the last `LOOKBACK_HOURS` are touched — it won't reply to a year of old comments.
- **MODE: approve** = maximum safety while you build trust in the agent.
- Keep your keys **in credentials**, never paste them into nodes.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `403 insufficient permissions` on posting | Re-grant the `youtube.force-ssl` scope (see Step 2 warning) |
| Nothing happens | Run the Schedule Trigger manually and read the execution; check `CHANNEL_ID` |
| Replies sound off-brand | Edit the system prompt in `Business Setup` |
| Approvals sheet fills up but nothing posts | Set rows to `APPROVED`, confirm `Post-Approved-Replies` is **Active** |
| A node shows a red "version" warning after import | n8n is upgrading an older node — accept it |

---

Built by [@AutomateWithAli](https://www.youtube.com/@AutomateWithAli) — AR Automation Labs.
More free n8n workflows: [github.com/ar-automation-labs](https://github.com/ar-automation-labs)
