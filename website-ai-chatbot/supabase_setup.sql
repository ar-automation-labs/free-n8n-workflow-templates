-- ============================================================
-- AI Website Support Agent — Supabase Setup
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- 1. Enable the vector extension (lets Postgres store embeddings)
create extension if not exists vector;

-- 2. Table that holds your chunked knowledge base + its embeddings
create table if not exists documents (
  id bigserial primary key,
  content text,
  metadata jsonb,
  embedding vector(768)  -- 768 = Google Gemini embeddings dimension.
                          -- Using OpenAI embeddings instead? Change to 1536.
);

-- 3. Search function — this is what the n8n "DataBase" node calls
--    every time the agent needs to look something up.
create or replace function match_documents (
  query_embedding vector(768),
  match_count int default null,
  filter jsonb default '{}'
) returns table (
  id bigint,
  content text,
  metadata jsonb,
  similarity float
)
language plpgsql
as $$
#variable_conflict use_column
begin
  return query
  select
    id,
    content,
    metadata,
    1 - (documents.embedding <=> query_embedding) as similarity
  from documents
  where metadata @> filter
  order by documents.embedding <=> query_embedding
  limit match_count;
end;
$$;

-- 4. Speeds up search once you have more than a few hundred chunks.
--    Safe to run even on an empty table.
create index if not exists documents_embedding_idx
  on documents using ivfflat (embedding vector_cosine_ops)
  with (lists = 100);


-- ============================================================
-- OPTIONAL — Conversation memory table
-- ============================================================
-- You normally do NOT need to run this. The n8n "Memory" node
-- (Postgres Chat Memory) creates this table automatically the
-- first time someone actually chats with your agent.
--
-- Only run the block below if you want to pre-create it yourself
-- or customize it before first use.
-- ============================================================

-- create table if not exists chat_messages (
--   id serial primary key,
--   session_id varchar(255) not null,
--   message jsonb not null,
--   created_at timestamp with time zone default now()
-- );
--
-- create index if not exists idx_chat_messages_session
--   on chat_messages(session_id);
