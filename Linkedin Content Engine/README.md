# LinkedIn Content Engine (n8n)

A reusable, human-approved LinkedIn content workflow for creators, freelancers and small businesses.

**What it does:** Google Sheets idea → AI-assisted source research → draft → edit → Gemini image → Gmail preview and approval → LinkedIn post → sheet status update.

Your original content and final approval stay with you. **Nothing posts without Gmail approval.**

## Setup (about 5 steps)

1. Import `linkedin-content-engine.json` into n8n (Workflows → Import from file). Keep it **inactive** during setup.
2. Create a Google Sheet with a tab named **`Ideas`**. Row 1 must use these exact headers, in this order:

   `Idea | Notes | Status | Draft | Updated | Source | ID`

   Add a topic in **Idea**, optional instructions in **Notes**, and `New` in **Status**. The workflow takes the oldest `New`, `Queued` or blank-status idea. If none exists, it stops.
3. Open **YOUR SETTINGS** in n8n. Fill in your name, intended audience, writing voice, your email address, and **spreadsheet ID** (the long value between `/d/` and `/edit` in the Sheet URL). Adjust visual style if wanted.
4. Reconnect your own credentials in the three Google Sheets nodes, both Gmail nodes, the LinkedIn node, and the AI model nodes. Set **Publish to LinkedIn → Person** using the account selector after connecting LinkedIn. The included `YOUR_LINKEDIN_MEMBER_ID` is intentionally not real.
5. Run one test with a harmless sample idea. Check the post and image in Gmail and **Decline** while testing. Only activate the schedule when everything is correct.

## Models & dependencies

- **GPT-5 mini**: topic research with OpenAI's built-in web search. No Brave or Firecrawl required.
- **Claude Sonnet 5.5**: post writing, editing and art direction.
- **Gemini 3 Pro Image**: image generation (premium-quality option). If unavailable or too expensive, choose another image model in **Generate Image**.
- **Google Sheets, Gmail, LinkedIn**: input, review and publishing.

These model choices are editable. API use, search, image generation and hosting may incur charges. **n8n Cloud Gateway credits, when available, are account-specific and do not transfer with this template.** You need appropriate API/model access and credentials.

## Everyday use

Add one unique row in `Ideas` with an `Idea` and status `New`, then run the workflow manually or wait for the 9 AM schedule. Review the email preview (image attached); the next Gmail message provides **Approve and post** / **Decline**. The sheet's `Status` changes from `New` → `Drafted` → `Posted` or `Declined`.

If you decline, you can edit the idea and set `Status` back to `New`. Do not duplicate an existing `Idea` title.

## Notes

- Import is **disabled** by default. The JSON includes **no saved credential IDs, tokens, original user IDs, personal email addresses, or source spreadsheet IDs**.
- Google Sheets requires the exact `Ideas` tab and column headers listed above.
- Web search is done by the OpenAI Chat Model, so account/model support for its web-search tool is required. Disable or replace web search if your OpenAI account does not support it.
- LinkedIn image publishing may require permissions that depend on your LinkedIn account and n8n integration.
- Image-generation prompts request a portrait composition; the model/provider controls the delivered dimensions.
- No actual user posts, clients, results or screenshots should be fabricated. Always review the text **and** image.
- The workflow intentionally stops if no new idea exists. The 3-day Gmail approval timeout may need adjustment for your schedule.
- This is a **template**, not a guarantee of a completely zero-configuration import or a tested result across every account/version.

Built from a working personal n8n concept, generalized as a separate copy for public sharing.
