# ElevenLabs Voice Agent — Exact Setup (the voice side)

Creates the talking agent from the video and wires it to your n8n system.

## 1 · Create the agent
1. **elevenlabs.io** → **Agents** (Conversational AI) → **Create Agent**.
2. Name it whatever you like (e.g. `My Assistant`).

## 2 · Voice & first message
- **Voice:** preview a few and pick one that matches your style (a calm male US voice works well for this use case).
- **First message:** `Hey — I'm your assistant. Tell me what to do: email, calendar, Slack, or YouTube.`

## 3 · System prompt (paste into Agent → Prompt)
```
You are a personal work assistant. You are calm, direct, and brief — everything you say is SPOKEN, so: short sentences, plain words, no lists, no URLs, no emojis.

You are connected to real tools through the "run_task" webhook:
- Gmail: send, draft, reply, find emails, recent emails, delete
- Google Calendar: create events, check today / this week, update, delete
- Slack: post messages, read channels, update/delete messages
- YouTube: search, video details, comments, playlist adds

RULES:
1. The moment the user asks for ANY real action, call run_task with query = their full request (keep every detail: who, what, when, which channel or video) and context = anything useful from the conversation.
2. NEVER claim an action happened until run_task returns. If it errors, say so.
3. If run_task asks for confirmation or a missing detail, relay that question exactly, briefly.
4. If the user says "yes / confirm / do it" right after a confirmation question, call run_task again with the same task plus the word "confirmed".
5. General chat or questions about you: answer yourself in max 2 short sentences.
6. Dates/times: resolve "tomorrow 4pm" using the user's timezone (ask once if you don't know it).
7. Never invent email addresses, event times, messages, or video titles.
```

## 4 · Add the webhook tool (the hands)
1. Agent → **Tools** → **Add tool** → **Webhook**.
2. Name: `run_task`
3. **Method:** POST · **URL:** `https://YOUR-N8N-DOMAIN/webhook/elevenlabs-actions`
4. **Body / parameters:** two strings:
   - `query` (required) — the full user request
   - `context` (optional) — conversation context
5. Save, then use the built-in **Test chat / call** and try:
   - "What's on my calendar today?"
   - "Email Sam the proposal — subject 'Proposal', say I'll call him Thursday."
   - "Post in Slack: demo is ready"
6. You should hear real results. If not: check n8n → Executions (usually a credential not connected or a sub-agent workflow ID not set).

## 5 · Deploy
- **Widget:** Agent → Deploy → Widget → embed on your site.
- The ElevenLabs test console works immediately; phone/WhatsApp channels can be added later from the same Deploy tab.

## Cost honesty
- ElevenLabs agent minutes (free tier is enough to test), OpenAI tokens per action (cents with gpt-4o-mini), Google/Slack APIs free at this scale.
