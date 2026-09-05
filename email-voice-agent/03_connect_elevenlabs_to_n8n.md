# Connect your ElevenLabs Agent to n8n (5 minutes)

## A. n8n side (do first)
1. Import `02_gmail_subagent_workflow.json` → open its **Settings** (or URL) and copy the **Workflow ID** (the string at the end of the URL).
2. Import `01_main_voice_agent_workflow.json` → open the **Gmail Sub-Agent (Tool)** node → Source: *Database* → select the Gmail sub-workflow you just imported → press **Refresh** on *Workflow Inputs* (query + caller_id should appear) → Save.
3. Attach credentials: **OpenAI API key** on both *OpenAI Chat Model* nodes; **Google OAuth2 (Gmail)** on every *Gmail – …* node.
4. **Activate BOTH workflows** (top-right toggle). A sub-workflow that isn't published/active makes the tool fail with "Workflow is not active".
5. On the **Webhook – Voice Agent** node copy the **Production URL** (not the test URL). It looks like `https://your-n8n/webhook/voice-email-agent`.

## B. ElevenLabs side
1. ElevenLabs → **Conversational AI → Agents → New Agent**. Give it a name ("Ali's Inbox Agent"), pick a voice, and paste a short persona prompt (you can reuse the MAIN system message from workflow 01).
2. Open the agent's **Tools → Add Tool** and create a **webhook / HTTP tool (server-side tool)**:
   - Name: `ask_email_agent`
   - Description: *"Ask Ali's email agent to read, summarize, send, draft, reply or label Gmail. Use for any email request from the caller."*
   - Method: **POST**
   - URL: the **Production webhook URL** from step A.5
   - Body parameter: `query` (string) — *"the caller's request rewritten as one clean instruction"* (the ElevenLabs LLM fills it from the conversation)
   - Optional: add a static header `Authorization: Bearer YOUR_SECRET` and validate it in the n8n webhook.
3. In the agent prompt add one line: *"For anything about email, call ask_email_agent and speak its reply."*
4. **Test** in the Conversational AI widget: say *"Do I have unread mail?"* → the tool panel should show a POST to your webhook and the agent should speak the inbox result.
5. Done — the same webhook works for the web widget, the ElevenLabs phone/SIP trunk, or any custom client that POSTs `{ "query": "...", "conversation_id": "..." }`.

## C. Verify it end-to-end
- n8n → Executions of the MAIN workflow: you should see Webhook → Set → Agent → (tool) → Respond, and a linked sub-execution of the Gmail workflow.
- If the agent says it "couldn't retrieve data": check (1) sub-workflow is **active**, (2) tool node has the sub-workflow selected + inputs refreshed, (3) you used the **production** webhook URL, (4) Gmail OAuth scopes include send.
