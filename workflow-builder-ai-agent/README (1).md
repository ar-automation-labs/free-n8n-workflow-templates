# 🤖 n8n Workflow Builder Agent

**An AI agent you chat with that builds other n8n automations for you — and installs them into your n8n with one message.**

Type what you want in plain English. The agent reads the n8n node docs, designs the workflow, generates valid n8n JSON, calls your n8n API to create it, and replies with a direct link to your brand-new workflow.

> `When a Typeform is submitted → add the lead to Google Sheets → post a summary to Slack` → ✅ built in ~20 seconds.

---

## ⚡ What it does

1. **Chat Trigger** — you send a natural-language request in the n8n chat panel.
2. **Fetch n8n Docs** — pulls the live n8n node reference (HTTP Request; fails safe).
3. **Workflow Builder Agent** — an LLM (default: OpenRouter **GPT-4.1-mini**, swappable to Claude/GPT-4o) writes a complete, importable n8n workflow with nodes, connections, settings and sticky notes.
4. **Clean Workflow JSON** — a Code node strips markdown fences, fixes common JSON errors, and guarantees valid output.
5. **Create Workflow in n8n** — uses the n8n API node to create the workflow directly in your instance.
6. **Return Workflow Link** — replies in chat with a clickable link to open and activate the new workflow.

Runs on **your own n8n** (self-hosted or n8n Cloud). Two credentials total.

---

## 🧩 Requirements

- An n8n account (self-hosted, or **n8n Cloud** — the built-in n8n API node works on both).
- An [**OpenRouter**](https://openrouter.ai/) API key (cheapest; GPT-4.1-mini ≈ **$0.01–0.02 per workflow built**).
- An **n8n API key** (Settings → n8n API → Create an API key).

---

## 🚀 Setup (3 minutes)

1. **Import**
   In n8n: **Workflows → ⋯ (top right) → Import from File** → select `workflow-builder-agent.json`.

2. **Connect the OpenRouter credential**
   - Click the **OpenRouter GPT-4.1-mini** node → *Credential* → *Create New*.
   - Paste your OpenRouter API key (from [openrouter.ai/keys](https://openrouter.ai/keys)). Save.

3. **Connect the n8n API credential**
   - Click **Create Workflow in n8n** → *Credential* → *Create New*.
   - Paste your n8n API key (n8n: **Settings → n8n API → Create an API key**).
   - For self-hosted, set the n8n base URL to your instance; for Cloud it's automatic. Save.

4. **Set your domain**
   - Open the **Return Workflow Link** node and replace
     `https://YOUR-N8N-DOMAIN.app.n8n.cloud` with your actual n8n URL
     (e.g. `https://yourname.app.n8n.cloud`).

5. **Save**, open the **Chat** panel (bottom-left chat icon), and send a request.

---

## 💬 Example prompts to try

- *"When a Typeform is submitted, add the contact to Google Sheets and post their answers to a Slack channel."*
- *"Every morning at 9am, pull new rows from a Google Sheet and send me a summary email via Gmail."*
- *"When someone books a Calendly event, create a Notion page and DM me on Slack."*
- *"Watch an RSS feed; when there's a new post, send it to Discord."*
- *"Webhook that takes a Stripe payment, adds the customer to Airtable, and emails a receipt with Gmail."*

Tip: name the trigger, the app(s), and the outcome — the more specific, the cleaner the build.

---

## 🔁 Swapping the AI model (optional)

GPT-4.1-mini handles 95% of builds cheaply. For complex multi-agent workflows:
- **Claude (best quality):** delete the OpenRouter model node → add a **Basic LLM (Anthropic)** node → connect it into the agent's *Language Model* input → add your Anthropic key. Claude handles large JSON especially well.
- **OpenAI GPT-4o:** same swap with a **Basic LLM (OpenAI Chat)** node.
- Or keep OpenRouter and change the model field to `anthropic/claude-3.5-sonnet` or `openai/gpt-4o`.

---

## 🛠️ Troubleshooting

- **"Create Workflow" fails / 401** → n8n API key missing or wrong; reconnect it. On self-hosted make sure the n8n node's base URL matches your instance.
- **Model returns markdown instead of JSON** → the **Clean Workflow JSON** Code node strips ` ```json ` fences automatically; if a build still fails, just re-send the request once.
- **Generated workflow has a placeholder credential** → open the new workflow and connect that app's credential (the sticky notes tell you which).
- **Chat shows raw JSON instead of a friendly reply** → the agent still builds correctly; the final **Return Workflow Link** node formats the clickable link.
- **Docs fetch errors** → non-blocking by design; the agent works from its built-in n8n knowledge even if that node fails.

---

## 🔒 Notes

- Only **you** have your API keys; the workflow lives in your own n8n instance.
- Costs: OpenRouter usage is per-request and very low for GPT-4.1-mini.
- The agent builds workflows but does not activate them — review and flip **Active** yourself (safer).

---

### Free workflow — from the video
Built in n8n. Star the repo and share what you build.
