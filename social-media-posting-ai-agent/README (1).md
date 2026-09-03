# 🚀 Post Once → Everywhere (n8n + Blotato)

**You add one video to a Google Sheet. It auto-posts to Instagram, TikTok, YouTube, Facebook, LinkedIn, X, Threads, Pinterest and Bluesky — then marks itself done.**

No more uploading the same reel nine times. n8n watches the sheet, Blotato does the actual posting to all 9 platforms, and the row flips to `Posted` (or `Errored` so you know to check).

---

## What's in the pack

| File | What it is |
|---|---|
| `post-once-everywhere.json` | The n8n workflow (import this) |
| `content-queue-template.xlsx` | The Google Sheet structure — import/use to make your sheet |

---

## ⚙️ What it does

1. **Schedule Trigger** — checks every 15 minutes.
2. **Get Next Ready Post** — finds the first row with Status = `Ready To Post`.
3. **Extract Drive ID** — pulls the Google Drive file ID out of your media link.
4. **Upload Media to Blotato** — sends the video to Blotato.
5. **9 platform nodes** — Instagram, TikTok, YouTube, Facebook, LinkedIn, X, Threads, Pinterest, Bluesky — all fire from that one upload.
6. **Mark Posted / Mark Errored** — flips the sheet row to `Posted`, or `Errored` if something failed.

---

## 🧰 Requirements

- [n8n](https://n8n.io) (self-hosted or n8n Cloud)
- A [Blotato](https://blotato.com) account — this is the tool that posts to all 9 platforms. It has a **7-day free trial**, then a paid plan (it handles the Instagram/TikTok/LinkedIn API approvals for you, which is why it's used instead of connecting 9 APIs yourself).
- A Google account for the Sheet + Drive.

---

## 🚀 Setup (~5 minutes)

### 1. Create your content sheet
- Open `content-queue-template.xlsx` and import it into **Google Sheets** (or copy the 4 columns: `Title`, `Media URL`, `Caption`, `Status`).
- Upload each video to **Google Drive**, make it "anyone with link can view", and paste the share link into `Media URL`.
- Set `Status` to **`Ready To Post`** when you want it to go out.
- Copy the sheet's ID from its URL (the long code between `/d/` and `/edit`).

### 2. Install the Blotato community node in n8n
- n8n → **Settings → Community Nodes → Install** → install **`@blotato/n8n-nodes-blotato`**.
- (It's Blotato's official n8n node.)

### 3. Import the workflow
- n8n → **Workflows → ⋯ → Import from File** → choose `post-once-everywhere.json`.

### 4. Add credentials
- **Google Sheets OAuth2** credential → connect it on the 3 Google Sheets nodes.
- **Blotato API key**: create a Blotato account → copy your API key → make a Blotato credential → it's already wired to all Blotato nodes.

### 5. Paste your IDs
- In every Google Sheets node, replace `REPLACE_WITH_YOUR_SHEET_ID` with your sheet ID.
- In the **Facebook** node, pick/enter your Facebook **Page ID** (Blotato posts to Pages, not personal profiles).
- In the **Pinterest** node, enter your **Board ID**.
- Connect your social accounts inside the **Blotato dashboard** first (that's where the actual logins live).

### 6. Activate
- Flip the workflow **Active**. Add a `Ready To Post` row and wait for the next run — or hit **Execute Workflow** to test immediately.

---

## 📝 How you use it day-to-day

Drop a new row into the sheet:
- **Title** → post title (used for YouTube title + first line)
- **Media URL** → your Google Drive video link
- **Caption** → the caption for all platforms
- **Status** → `Ready To Post`

When it posts, Status becomes **`Posted`**. If a platform rejects it, Status becomes **`Errored`** — check that platform's requirements in Blotato.

---

## 💡 Tips
- Make sure Drive links are **shared (anyone with link)** — locked files can't be read.
- Vertical video (9:16) works best across Shorts/Reels/TikTok.
- Want it to post more/less often? Change the Schedule interval.
- Don't need all 9? Just delete that platform's node.

---

### Free workflow + sheet
The n8n workflow and the sheet template are free. Blotato itself is a paid service after its 7-day trial — it's the one piece that actually publishes to the platforms.
