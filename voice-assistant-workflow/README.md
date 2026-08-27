# AI Voice Assistant — n8n Automation System

The system from the video: **you talk → ElevenLabs voice agent → this n8n system → real actions** in Gmail, Google Calendar, Slack, and YouTube. Importable by anyone in ~5 minutes.

## Architecture

```
                        ┌─────────────────────────────────────────────┐
   You (talking)        │  n8n                                        │
   ───────────►  ElevenLabs Voice Agent (the voice + the brain)      │
                        │   │ webhook tool "run_task"                │
                        │   ▼                                        │
                        │  1-main-architect.json                      │
                        │  Webhook /elevenlabs-actions               │
                        │  → Extract Request (query, context)        │
                        │  → Main Architect Agent (router ONLY)      │
                        │     ├─► 2-email-agent.json     (Gmail)     │
                        │     ├─► 3-calendar-agent.json (Calendar)   │
                        │     ├─► 4-slack-agent.json    (Slack)      │
                        │     └─► 5-youtube-agent.json   (YouTube)   │
                        │  → Build Voice Reply (≤2 spoken sentences) │
                        │  ← JSON response ElevenLabs speaks         │
                        └─────────────────────────────────────────────┘
```

The **Main Architect never executes anything** — it classifies the intent, hands the full task to exactly one specialist, handles follow-ups (confirmations, missing details), and returns a voice-ready reply.

Each sub-agent = an AI specialist that picks ONE operation and fills parameters (enforced by a structured output parser) — then **deterministic n8n nodes do the actual work**. The LLM never freestyles API calls. Dangerous actions are confirmation-gated, and half-filled requests ask for the missing piece instead of executing.

## What each agent can do

| Agent | Operations |
|---|---|
| **Email (Gmail)** | send · draft · reply · find/search · get recent · delete (confirm-gated) |
| **Calendar (Google)** | create · today · this week · find · update (confirm) · delete (confirm) |
| **Slack** | post · read channel · update message (confirm) · delete message (confirm) |
| **YouTube** | search · details+stats · comments · add to playlist (confirm, OAuth) · delete video (confirm, OAuth) |

## Import order (5 minutes)

1. **Import the 4 sub-agents first** (Workflows → Add → Import from File): `2-email-agent.json`, `3-calendar-agent.json`, `4-slack-agent.json`, `5-youtube-agent.json`.
2. Open each imported workflow and copy its **workflow ID** from the URL (`.../workflow/<ID>/edit`).
3. Import `1-main-architect.json`. In each of the 4 tool nodes (`email_agent`, `calendar_agent`, `slack_agent`, `youtube_agent`) replace the `REPLACE_WITH_..._ID` placeholder with the matching ID (or just pick the workflow from the dropdown).
4. Connect credentials (table below) on every node marked `REPLACE_...`.
5. Edit the **Business Setup** node (main workflow) and each sub-agent's **App Config** node — your name, timezone, default Slack channel, YouTube API key.
6. **Activate all 5 workflows.**
7. Test the pipeline directly:
```bash
curl -X POST https://YOUR-N8N/webhook/elevenlabs-actions \
  -H "Content-Type: application/json" \
  -d '{"query":"What is on my calendar today?","context":"test"}'
```
8. Connect the voice side → `ELEVENLABS_SETUP.md`.

## Credentials to create (n8n → Credentials)

| Credential (exact type) | Used in |
|---|---|
| **OpenAI API** (or swap the GPT Model node to any provider) | all 5 workflows |
| **Gmail OAuth2** | Email agent |
| **Google Calendar OAuth2** | Calendar agent |
| **Slack OAuth2** | Slack agent |
| **YouTube Data API v3 key** (Google Cloud → enable YouTube Data API → API key) | YouTube agent — paste into its **App Config** node |
| *(optional)* **Google/YouTube OAuth2** as a credential on the two flagged HTTP nodes | YouTube playlist-add & delete-video |

## How the safety loops work

- **Destructive action** (delete email/event/message, playlist add, delete video): the specialist returns `needs_confirmation: true` → the voice agent asks you to confirm → your "yes" re-sends the same task with "confirmed" → the specialist executes (it never asks twice).
- **Missing detail** ("send an email" with no recipient): the specialist returns `missing_info` with one short question — nothing executes half-filled.
- **Errors** surface honestly ("that didn't work") — never fake success.

## Production notes (honest)

- **Timeout:** ElevenLabs waits ~20s on webhook tools. gpt-4o-mini + one app call fits comfortably. If a provider is slow, switch the webhook to *Immediately* response and inspect results in n8n executions.
- **Public URL:** n8n must be reachable over HTTPS for ElevenLabs to call it (n8n Cloud is fine as-is).
- **Extend:** add a sub-agent (WhatsApp, Sheets, Notion…) by copying the pattern, then add one toolWorkflow node + one line in the architect's prompt. That's the whole pattern.
- **Privacy:** message content passes through your LLM provider for parameter extraction only. Once live, keep API keys in n8n credentials rather than App Config where possible.

## Files
`1-main-architect.json` · `2-email-agent.json` · `3-calendar-agent.json` · `4-slack-agent.json` · `5-youtube-agent.json` · `ELEVENLABS_SETUP.md` · this README.
