# AI Inbox Manager for n8n

A free n8n workflow that watches Gmail, classifies new emails, applies useful labels, summarizes newsletters, and can optionally send summaries to Slack or create Google Calendar events.

## What it does

1. Checks Gmail for new email every 5 minutes.
2. Cleans the email body.
3. Classifies the email with AI.
4. Applies one Gmail label.
5. Summarizes newsletters.
6. Optionally sends the summary to Slack.
7. Optionally extracts dates and creates calendar events.

## Default categories

| Category | Use |
|---|---|
| `URGENT` | Needs action within 24 hours |
| `WORK` | Client, team, project, school, finance, or business |
| `PERSONAL` | Direct messages from personal contacts |
| `NEWSLETTER` | Newsletters, digests, webinars, and educational content |
| `AUTOMATED` | Receipts, OTPs, shipping, confirmations, and system alerts |
| `SPAM` | Scams, phishing, suspicious links, or unwanted promotion |
| `REVIEW` | The AI is not sure |

## Setup

### 1. Import the workflow

1. Download `inbox-ai-assistant-n8n-workflow.json`.
2. Open n8n.
3. Create a new workflow.
4. Choose **Import from File**.
5. Select the JSON file.
6. Keep the workflow inactive until testing is complete.

### 2. Add your credentials

Open these nodes and select your own credentials:

- **New Email** and every **Apply ... Label** node: Gmail OAuth2
- **Groq Chat Model**: Groq API credential
- **OpenAI Chat Model**: OpenAI API credential

No credentials, tokens, email addresses, or private IDs are included in this repository.

### 3. Create Gmail labels

Create these labels in Gmail, or use your own names:

- Personal
- Work
- Newsletter
- Automated
- Spam
- Urgent
- Needs Review

Then open every **Apply ... Label** node and select the correct Gmail label. The imported placeholder IDs will not work until you choose your labels.

### 4. Test it

Send test emails for every category. Check the execution output and Gmail labels. When everything works, activate the workflow.

## Customize the classifier

Open **Email Classifier** to change the rules.

If you add, remove, or rename a category, update all three places:

1. The **Email Classifier** prompt
2. The **Route by Category** rules
3. The matching Gmail label node

The classifier treats email content as untrusted data and sends uncertain results to `REVIEW`.

## Optional Slack summary

**Send Summary to Slack** is disabled by default.

To use it:

1. Add your Slack credential.
2. Select your Slack channel.
3. Enable the node.

If you do not use Slack, leave the node disabled or delete it.

## Optional Google Calendar

The calendar section is disabled by default.

To use it:

1. Set the correct timezone in the n8n workflow settings. The template starts with `UTC`.
2. Add your Google Calendar credential.
3. Open **Create Calendar Event** and select your calendar.
4. Enable these three nodes:
   - **Extract Event Details**
   - **Parse Event Details**
   - **Create Calendar Event**
5. Test with a sample event email before using it on your real inbox.

Do not want calendar events? Simply delete those three nodes.

## AI models

The template starts with:

- Groq `openai/gpt-oss-120b` for classification
- OpenAI `gpt-4o-mini` for summaries and optional event extraction

You can replace them with supported chat models. Test the classifier again after changing a model.

## Privacy and safety

- Email text is sent to the AI providers you connect.
- Review the privacy policy of each provider before using a real inbox.
- Never commit API keys, OAuth tokens, credential exports, private email addresses, Gmail label IDs, Slack channel IDs, or calendar IDs.
- Keep the workflow inactive while setting it up.
- The prompts tell the AI to treat email content as untrusted data, but you should still review important results.

## Troubleshooting

**Emails receive no label**  
Check the execution output from **Normalize Category**. Invalid AI output is changed to `REVIEW`.

**A Gmail label node fails**  
Open that node and select a real label from your Gmail account. Do not leave the placeholder ID.

**Slack fails**  
Select a Slack credential and channel, or keep the optional node disabled.

**Calendar creates the wrong time**  
Set the workflow timezone correctly and test the event extractor again.

## Workflow file

`inbox-ai-assistant-n8n-workflow.json`

Built for the AutomateWithAli community.
