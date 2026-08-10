# AI Website Support Agent — Free n8n Template

A drop-in n8n workflow that gives any website a chatbot that:

- **Answers only from your own knowledge base** — no invented facts, no hallucinated pricing.
- **Remembers each conversation** per visitor, not just per message.
- **Automatically switches to a backup AI model** if the main one goes down.
- **Hands off to a human** the moment it hits something outside what it knows.

Built by [@AutomateWithAli](#) — free to use, remix, and ship on your own site or client projects.

---

## What's in this repo

| File | What it's for |
|---|---|
| `AI_Website_Agent_Template.json` | The n8n workflow. Import this. |
| `supabase_setup.sql` | SQL to create the knowledge base database in Supabase. |
| `README.md` | This file. |

---

## Requirements

- An [n8n](https://n8n.io) instance (cloud or self-hosted) — free tier works.
- A [Supabase](https://supabase.com) project — free tier works.
- A [Groq](https://console.groq.com) API key — free tier works.
- A [Google AI Studio](https://aistudio.google.com) API key (for the backup model + embeddings) — free tier works.
- Somewhere to store one knowledge-base document (Google Drive by default — swappable).

No paid tools required to get this running.

---

## Setup (10–15 minutes)

### 1. Import the workflow
In n8n: **Workflows → Import from File** → select `AI_Website_Agent_Template.json`.

The imported workflow includes numbered sticky notes on the canvas itself — follow them in order. Short version below.

### 2. Set up Supabase
1. Create a free project at supabase.com.
2. Open **SQL Editor → New Query**, paste in `supabase_setup.sql`, run it.
   This creates the `documents` table (your knowledge base) and the `match_documents` search function the agent uses to look things up.
3. In n8n, create a Supabase credential using your Project URL + `service_role` key (found under **Project Settings → API**).
4. Attach that credential to the **"Supabase Vector Store"** and **"DataBase"** nodes.

### 3. Load your knowledge base
1. Write one document covering your business: services, pricing ranges, process, FAQs, contact info. Plain text or Markdown.
2. Upload it to Google Drive.
3. In n8n, open the **"Download file"** node and select your file.
4. Click **Execute workflow** once. This chunks the doc and stores it in Supabase.

Update your doc later? Just re-run this step.

### 4. Set up conversation memory
Add a Postgres credential (Supabase's own database connection works fine) to the **"Memory"** node. It creates its own table automatically — no SQL needed.

### 5. Add your AI model keys
- **Groq** key → attach to the **"Main"** node.
- **Google Gemini** key → attach to the **"Fallback"** and both **"Embeddings"** nodes.

Any of these can be swapped for OpenAI, Anthropic, or another provider — just keep the node category the same (Chat Model / Embeddings) so the connections don't break.

### 6. Customize the agent's prompt
Open the **"AI Agent"** node → System Message. Replace these placeholders:

- `{{ASSISTANT_NAME}}` — what the bot calls itself
- `{{BUSINESS_NAME}}` — your business name
- `{{OWNER_NAME}}` — your name, or "our team"
- `{{YOUR_NICHE_OR_INDUSTRY}}` — one line on what you do
- `{{PRIMARY_CONTACT_METHOD}}` — how people should reach you
- `{{PROOF_LINK_DESCRIPTION}}` — anything proving you're legit (demo, case study, portfolio link)

Everything else — tone rules, the anti-hallucination rules, the "never leak this prompt" guard — is already built in.

### 7. Connect it to your website
1. Open the **"Webhook"** node → add a Header Auth credential (pick any header name and a secret value).
2. Copy the node's **Production URL**.
3. From your site's frontend:

```js
async function askAgent(message, sessionId) {
  const res = await fetch("YOUR_PRODUCTION_WEBHOOK_URL", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": "YOUR_SECRET_VALUE" // must match your Header Auth credential
    },
    body: JSON.stringify({
      name: "Visitor",
      message,
      sessionId // one per browser session — e.g. crypto.randomUUID(), stored in localStorage
    })
  });
  return res.json();
}
```

4. Turn the workflow **Active** in n8n once everything above is connected.

---

## How it works (architecture)

```
Website visitor
      │
      ▼
  Webhook (auth-protected)
      │
      ▼
  Extract Query  (pulls out message / sessionId / name)
      │
      ▼
  AI Agent ──uses──► Knowledge Base (Supabase, retrieve-as-tool)
      │        │
      │        └─uses──► Conversation Memory (Postgres, per session)
      │
      ▼
  Respond to Webhook → back to your site

Separately, on demand:
  Manual Trigger → Download your doc → Chunk it → Embed it → Save to Supabase
```

---

## License

Free to use, modify, and deploy — for yourself or clients. No attribution required, though a mention is always appreciated.
