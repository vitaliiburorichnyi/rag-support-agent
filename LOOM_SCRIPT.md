# Loom script — RAG Support Knowledge Agent (target: ~2 minutes)

Record in one take if possible. Screen: n8n canvas, switching between the production workflow and Supabase table view. Keep energy up, talk while things load rather than pausing.

---

**[0:00–0:15] Hook — the problem, on screen: open the OLD version of the email support workflow (or just describe it if not kept)**

> "This email support system used to answer customer questions from hardcoded rules baked into one giant prompt. That works until the policy changes, or someone asks something the prompt didn't anticipate — then it either guesses or breaks. I rebuilt the answer layer to pull from a real, versioned knowledge base instead."

**[0:15–0:35] Show the knowledge base — screen: Supabase table editor, `documents` table**

> "Ten real support docs — shipping, returns, product care, sizing, FAQs — chunked and embedded into Postgres with pgvector. Any time I edit one of these source docs in Drive, this table re-ingests it automatically: old chunks for that doc get deleted, new ones get embedded and inserted. No manual re-indexing."

**[0:35–1:05] Run a live query — screen: n8n, trigger the email workflow (or eval workflow) with a real question, e.g. "How do I care for my suede clutch?"**

> "Watch what happens on a real question. The email gets embedded, we search for the 5 closest chunks by cosine distance — [point at the Retrieve KB Chunks node executing] — here's the actual context that comes back: Product Care, Canvas & Suede Bags. Claude answers using *only* this retrieved text, and cites it. [switch to output] Here's the generated answer — suede brush, one direction, no water, cites the source doc by name."

**[1:05–1:30] Show the guardrail — screen: either replay the out-of-KB test, or describe it**

> "If I ask something this knowledge base doesn't cover — say, whether they take Bitcoin — two independent things stop it from making something up: a confidence score on the retrieval itself, and a prompt instruction telling Claude not to infer a policy from an adjacent list. Either one catches it, and instead of guessing, it escalates to a human with a logged reason."

**[1:30–1:50] Show the eval — screen: `eval_results` table or the summary node's output**

> "I didn't just eyeball this — I built a 30-question golden set, 21 answerable and 9 deliberately outside the knowledge base, and ran it through an LLM judge that checks every answer against the actual retrieved context. Current numbers: 95% correct, 100% grounded, 100% of out-of-KB questions correctly escalated. And I logged every retrieval — question, chunks, score, answer — so this is auditable in production, not a black box."

**[1:50–2:00] Close**

> "Everything here — ingestion, retrieval, grounding, eval — is real n8n workflows and a real Supabase project, not a mockup. Repo's linked below with the full workflow exports and the eval breakdown."

---

## Notes for recording
- If narrating live execution is too slow/unpredictable, pre-run the query once, then walk through the *execution log* (n8n keeps full input/output per node) instead of waiting on a live call.
- Swap the suede example for whatever renders best on screen at record time.
- Keep the "known limitations" honesty (threshold overlap, the trade-in edge case) out of the video — that's for the README. The video's job is the happy-path story plus one guardrail example.
