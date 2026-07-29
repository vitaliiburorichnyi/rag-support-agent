-- RAG Support Knowledge Agent — Supabase schema
-- Requires the pgvector extension: create extension if not exists vector;

-- Knowledge base chunks + embeddings
create table if not exists documents (
  id bigserial primary key,
  content text not null,
  embedding vector(1536),          -- OpenAI text-embedding-3-small
  created_at timestamptz not null default now(),
  metadata jsonb                   -- { doc_id, title, source_url, category }
);

create index if not exists documents_embedding_idx
  on documents using hnsw (embedding vector_cosine_ops);

-- Day 4: per-request retrieval observability
create table if not exists retrieval_logs (
  id bigserial primary key,
  created_at timestamptz not null default now(),
  email_id text,
  email_subject text,
  customer_message text,
  retrieved_chunks jsonb,          -- [{ title, url, score }, ...]
  best_score double precision,     -- cosine distance, lower = more similar
  low_confidence boolean,
  requires_human boolean,
  escalation_reason text,
  final_response text
);

-- Day 5: golden eval set (20 answerable + 10 out-of-KB questions)
create table if not exists golden_eval_set (
  id bigserial primary key,
  question text not null,
  expected_answer text not null,   -- brief ground-truth summary, not exhaustive
  is_answerable boolean not null,
  category text
);

-- Day 5: eval run results, one row per golden question per run
create table if not exists eval_results (
  id bigserial primary key,
  run_at timestamptz not null default now(),
  golden_id bigint,
  question text,
  expected_answer text,
  is_answerable boolean,
  predicted_answer text,
  requires_human boolean,
  retrieval_best_score double precision,
  grounded boolean,
  correct boolean,
  escalation_correct boolean,
  judge_notes text
);
