# Eval Results — 30-question golden set

Run date: 2026-07-27. Model: Claude Sonnet 4.6 (generation + judge), OpenAI `text-embedding-3-small` (retrieval).

**Summary: 20/21 answerable correct (95%) · 21/21 grounded (100%) · 9/9 out-of-KB questions correctly escalated (100%)**

| # | Category | Question | Answerable? | Correct | Grounded | Escalation correct | Best score* |
|---|---|---|---|---|---|---|---|
| 1 | shipping | How long does domestic shipping take and how much does it cost? | Yes | ✅ | ✅ | ✅ | 0.495 |
| 2 | shipping | What happens if my package has not moved in tracking for over a week? | Yes | ✅ | ✅ | ✅ | 0.620 |
| 3 | shipping | Can I change my delivery address after ordering? | Yes | ✅ | ✅ | ✅ | 0.559 |
| 4 | returns | How many days do I have to return a bag? | Yes | ✅ | ✅ | ✅ | 0.448 |
| 5 | returns | How long until I get my refund after returning an item? | Yes | ✅ | ✅ | ✅ | 0.490 |
| 6 | returns | I received the wrong item, what do I do? | Yes | ✅ | ✅ | ✅ | 0.612 |
| 7 | returns | Can I exchange my bag for a different color? | Yes | ✅ | ✅ | ✅ | 0.547 |
| 8 | product-care | How do I clean a stain on my leather bag? | Yes | ✅ | ✅ | ✅ | 0.379 |
| 9 | product-care | Can I get my canvas tote wet or put it in the dryer? | Yes | ✅ | ✅ | ✅ | 0.435 |
| 10 | product-care | How do I care for my suede clutch? | Yes | ✅ | ✅ | ✅ | 0.391 |
| 11 | sizing | Will my 14 inch laptop fit in the Everyday Tote? | Yes | ✅ | ✅ | ✅ | 0.452 |
| 12 | sizing | What are the dimensions of the Mini Tote? | Yes | ✅ | ✅ | ✅ | 0.362 |
| 13 | orders-payments | Can I cancel my order after placing it? | Yes | ✅ | ✅ | ✅ | 0.555 |
| 14 | orders-payments | Do you offer buy-now-pay-later like Klarna? | Yes | ✅ | ✅ | ✅ | 0.527 |
| 15 | orders-payments | Can I use two discount codes on one order? | Yes | ✅ | ✅ | ✅ | 0.590 |
| 16 | warranty | What does the warranty cover? | Yes | ✅ | ✅ | ❌ | 0.670 |
| 17 | warranty | Is the City Satchel genuine leather? | Yes | ✅ | ✅ | ✅ | 0.433 |
| 18 | packaging | Do I need to keep the box to return an item? | Yes | ✅ | ✅ | ✅ | 0.519 |
| 19 | packaging | Do you have a bag recycling program? | Yes | ✅ | ✅ | ✅ | 0.482 |
| 20 | catalog | When will the sold-out Weekender restock? | Yes | ✅ | ✅ | ✅ | 0.518 |
| 21 | out-of-kb | Do you sell dog leashes or pet accessories? | No | ✅ | ✅ | ✅ | 0.695 |
| 22 | out-of-kb | Can I pay using Bitcoin or another cryptocurrency? | No | ✅ | ✅ | ✅ | 0.641 |
| 23 | out-of-kb | Do you have a physical retail store I can visit in New York? | No | ✅ | ✅ | ✅ | 0.739 |
| 24 | out-of-kb | Can I get a custom bag made with my initials engraved? | No | ✅ | ✅ | ✅ | 0.595 |
| 25 | out-of-kb | Do you offer a student or military discount? | No | ✅ | ✅ | ✅ | 0.664 |
| 26 | out-of-kb | What is your policy on wholesale/bulk orders for corporate gifts? | No | ✅ | ✅ | ✅ | 0.648 |
| 27 | packaging | Can I trade in my old non-Hush bag for a discount on a new one? | Yes† | ❌ | ✅ | ❌ | 0.418 |
| 28 | out-of-kb | Do you ship internationally to Antarctica research stations? | No | ✅ | ✅ | ✅ | 0.630 |
| 29 | out-of-kb | What horsepower is needed to tow a trailer with a Weekender bag attached? | No | ✅ | ✅ | ✅ | 0.730 |
| 30 | out-of-kb | Can you help set up a payment plan through my employer's benefits program? | No | ✅ | ✅ | ✅ | 0.711 |

\* Cosine distance — lower means more similar. Escalation threshold: 0.65.
† Originally logged as out-of-KB; relabeled after eval review — the packaging doc explicitly covers "no take-back program for non-Hush items," making this answerable.

## The two remaining "failures," explained

**#16 (warranty) — false-positive threshold escalation.** The answer was correct and fully grounded, but its best retrieval score (0.670) landed just above the 0.65 cutoff, so the confidence guardrail forced `requires_human=true` even though the generated answer was fine. This is the expected cost of a hard distance threshold: the answerable-question score range (0.36–0.67) and the out-of-KB range (0.59–0.74) overlap in the 0.59–0.67 band, so no single cutoff perfectly separates them. Worth revisiting with a larger eval set or a soft/two-tier threshold.

**#27 (packaging, "trade-in") — over-cautious escalation.** After tightening the system prompt in Day 5 to stop the model from inferring negative policy facts from an exhaustive list (the fix for the Bitcoin case, #22), the model became more conservative and now escalates this one instead of using the packaging doc's explicit "no take-back program" statement. Trade-off: zero hallucinations across all 30 cases, at the cost of one unnecessary escalation. Documented, not silently ignored.

## How this evolved (why it's not a one-shot 30/30)

1. First run: 8/10 out-of-KB questions escalated correctly. Investigation found one mislabeled golden question and one genuine gap — the model inferred "Bitcoin not accepted" from a payment-methods list instead of escalating.
2. Tightened the grounding prompt to stop inferring negatives from lists → escalation went to 9/9, but answerable accuracy *dropped* (17/21). Investigation found the judge itself was flawed — it compared "groundedness" against a one-line summary instead of the actual retrieved text, penalizing correct answers that cited real KB facts the summary didn't mention.
3. Fixed the judge to check against retrieved context → final numbers above.
