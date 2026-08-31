# Meeting Notes → Sheet + Client Recap + Coach Note (n8n workflow)

When a call ends, your AI note-taker (Fireflies / Fathom / Granola) sends the transcript to this workflow. It:

1. **Reads the whole transcript** with an AI agent.
2. **Extracts** a summary, decisions, and action items (owner + due date).
3. **Logs everything to a Google Sheet** automatically.
4. **Emails your client** a clean recap with their next steps, in your tone.
5. **Emails you** one line: how the call went + how to do better next time.

---

## 1. Import (2 min)

1. Open n8n → **Workflows → Import from File**.
2. Pick `meeting-notes-workflow.json`.
3. You'll see 9 nodes. Any node with a red warning needs a credential (below).

## 2. Credentials you connect once

| Node | Credential to create |
|---|---|
| **Chat Model** | OpenAI API key (works with any OpenAI-compatible endpoint — OpenRouter, Groq, etc.). Use the model `gpt-4o-mini` (cheap, reliable) or swap to `gpt-4o`. |
| **Google Sheets** | Google Sheets OAuth2 (connect the Google account that owns your sheet). |
| **Gmail** (×2) | Gmail OAuth2 (the address you send from). Same credential on both. |

> Want **Gemini** instead of OpenAI? Delete the **Chat Model** node → add node **AI → LangChain → Model → Chat Model → Google Gemini** → connect it to the **AI Agent**'s *Language Model* input → pick your Gemini credential. Everything else stays the same.

## 3. The `2 · Setup` node — edit these fields (only place you customize)

Open the **Setup — edit your business info** node and set:

- `businessName` → your brand
- `senderName` → your name (this signs the client email)
- `yourEmail` → where the coach/debrief note goes
- `tone` → how the client email should sound (default: *warm, direct, professional*)
- `sheetId` → your Google Sheet ID (the long code in the sheet's URL)
- `sheetTab` → tab name (default `Meeting Log`)

## 4. Google Sheet setup

Create a sheet with a tab named **Meeting Log** and these headers in row 1:

```
Date | Client | Summary | Next steps | Owner | Action items | Coach note
```

(The workflow fills these by column name — order doesn't matter, names do.) Share the sheet with the Google account you connected.

## 5. The webhook URL

Open the **1 · Webhook** node, click **Listen for test call** (or **Execute workflow** once), and copy the **Test URL**. After activation you use the **Production URL**. It looks like:

```
https://<your-n8n>/webhook/meeting-transcript
```

It expects a `POST` with JSON body:

```json
{
  "transcript": "the full call transcript text...",
  "clientName": "Acme Co",
  "clientEmail": "client@acme.com",
  "callDate": "2026-08-31"
}
```

## 6. Connect Fireflies / Fathom / Granola to fire the webhook

These tools don't all POST to a webhook natively — the reliable path is one tiny bridge:

- **Fireflies:** Settings → **Zapier / native integrations**. Or use the **Fireflies API** (`/v1/transcripts`) in a separate schedule trigger that POSTs new transcripts here.
- **Fathom:** use Fathom's **share/summary export** + a Zapier/Make "New Fathom Note → **Webhooks → POST**" zap.
- **Granola:** export via its Zapier/Make connector → **Webhook → POST**.

In Zapier/Make the POST step is the same for all:
- **Method:** POST
- **URL:** your n8n production webhook URL
- **Body (JSON):**
  ```json
  {
    "transcript": "<full transcript field>",
    "clientName": "<meeting title / contact name>",
    "clientEmail": "<attendee email>",
    "callDate": "<meeting date>"
  }
  ```

## 7. Test it

1. In n8n click **Execute Workflow**.
2. With the webhook in "listen" mode, send a test POST (use Postman, `curl`, or the real bridge):
   ```bash
   curl -X POST https://<your-n8n>/webhook/meeting-transcript \
     -H "Content-Type: application/json" \
     -d '{"transcript":"We agreed to send the Q4 proposal by Tuesday. Sarah will confirm the budget. Next kickoff after scope is approved.","clientName":"Northwind","clientEmail":"you@example.com","callDate":"2026-08-31"}'
   ```
3. Check each node turns green, a row appears in your sheet, and two emails send.
4. **Activate** the workflow (top-right toggle) when happy.

## Customizing the output

- **Want different sheet columns?** Edit the mapping in node **5 · Log to Google Sheets**.
- **Want the email to say something specific?** The email text is generated from the prompt in node **3 · AI Agent** — edit the `clientEmailRecap` instructions there (it's clearly labeled).
- **Want Slack/Discord/WhatsApp instead of email?** Replace nodes **6/7** with that app's "send message" node; it receives the same parsed JSON (`summary`, `actionItems`, `coachNote`).

## Notes & safety

- Credentials in the file are placeholders (`REPLACE_WITH_YOUR_...`) — you connect real ones in n8n; nothing secret is stored in this JSON.
- The AI never invents facts: anything not on the call is marked **TBD**.
- The agent output is parsed defensively (node 4), so one malformed AI response won't break the run.
