# AI Form → Booked Call Agent (n8n)

The workflow from the video: someone fills your form → an AI qualifies them against **your** rules → it checks your Google Calendar for a real free slot → books the meeting → sends the confirmation email → saves the lead + AI summary into Supabase.

If the AI isn't sure, it doesn't guess — it pings you instead. If you're a fit but the week is full, the lead gets an honest "grabbing you a time" email, not silence.

## Setup (≈10 minutes)

1. **Import**: n8n → ⋯ menu → *Import from File* → pick `ai-form-to-booked-call-n8n.json`.
2. **Connect 4 accounts** (click each node with a warning badge and attach):
   - OpenAI API key (used: `gpt-4o-mini` — costs cents per 1,000 leads)
   - Google Calendar (OAuth) — the calendar that holds your meetings
   - Gmail (OAuth) — the address emails come from
   - Supabase — your project URL + `service_role` key (Settings → API)
3. **Create the table** in Supabase (SQL Editor → run once):

```sql
create table leads (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  name text, email text, need text, budget text, timeline text,
  fit text, service text, ai_summary text,
  booked boolean default false, slot_label text
);
alter table leads enable row level security; -- service_role key still writes fine
```

4. **Edit ONE node — "Business Setup"**: business name, your email, your services, your fit rules, your timezone. The AI's brain reads everything from there. That's the "swap in your questions/r rules" part — also edit the form fields on **New Lead Form** if you want different qualifying questions.
5. **Activate** the workflow, open the **New Lead Form** node, copy the production form URL, put that link everywhere (bio, website, WhatsApp).

## How it works (what to show people)

- **New Lead Form** — n8n-hosted form, 4 fit questions, instant "check your inbox ⚡" response.
- **Business Setup** — every placeholder lives here. One node, yours to edit.
- **Qualify Lead (AI)** — strict-JSON brain: `GOOD` / `NOT_FIT` / `REVIEW`, plus a skim-ready summary and a personal hook line for the email. Temperature 0.2, forced JSON — it cannot freestyle.
- **Parse AI Answer** — never crashes: unreadable AI output becomes `REVIEW`, never a booking.
- **Fetch Calendar Window → Find First Free Slot** — real date math in code (30-min meetings, 10:00–18:00, Mon–Fri, 15-min buffers, 2-hour notice). The AI never touches the calendar arithmetic.
- **Good Fit? / Free Slot?** — four honest paths: booked, qualified-but-full, kind not-fit follow-up, or "boss, check this one."
- **Save Lead in Supabase** — every single path ends in one clean row with the AI summary.

## Notes

- Test it once with your own email before sharing the link (use n8n "Test workflow").
- Emails are plain text on purpose — they land in inboxes, not the Promotions tab.
- Weekends off by default; edit the constants at the top of **Find First Free Slot** to change hours/days/length.

Made by [@AutomateWithAli](https://youtube.com/@AutomateWithAli) — video walkthrough linked in the description of the video that sent you here.
