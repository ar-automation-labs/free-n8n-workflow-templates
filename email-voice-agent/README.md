# Voice Email Agent — n8n + ElevenLabs Pack

Talk to your inbox: an ElevenLabs voice agent calls n8n; n8n thinks; a Gmail sub-agent acts.

## Files
| File | What it is |
|---|---|
| `01_main_voice_agent_workflow.json` | MAIN: Webhook (voice input) → Set (extract query) → AI Agent (OpenAI + memory) with **Gmail Sub-Agent as a tool** → Respond to Webhook |
| `02_gmail_subagent_workflow.json` | GMAIL SUB-AGENT: "When Executed by Another Workflow" → AI Agent with 7 Gmail tools (search, read, send, reply, draft, list labels, add label) |
| `03_connect_elevenlabs_to_n8n.md` | 5-minute guide: wire the ElevenLabs agent's webhook tool to the n8n production URL |
| `README.md` | This file |

## You need
- n8n (cloud or self-host), OpenAI API key, Google OAuth2 (Gmail) credential, ElevenLabs account.

## Setup (60 seconds after reading the guide)
1. Import **02** first, copy its Workflow ID.
2. Import **01**, open *Gmail Sub-Agent (Tool)*, pick the sub-workflow, Refresh inputs, Save.
3. Attach OpenAI + Gmail credentials; **activate both** workflows.
4. Copy the MAIN webhook **production URL**.
5. In ElevenLabs: create agent → add POST webhook tool `ask_email_agent` with that URL and a `query` parameter → test in widget.
6. Speak: *"Do I have unread mail?"* / *"Tell Sarah the invoice is on the way."*

## Placeholders to replace
- `REPLACE_WITH_GMAIL_SUBWORKFLOW_ID` in workflow 01 (or just re-pick the workflow in the tool node).
- Persona name/signature inside the two system messages.

All node types/versions verified against current n8n docs & packages (Gmail as AI tool, Call-n8n-Workflow tool v2.2, Execute-Workflow trigger v1.1, Agent v2.2, `$fromAI()` params).
