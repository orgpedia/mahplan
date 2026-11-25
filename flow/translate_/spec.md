# translate_: a Department's GRs in English

**Version:** 0.6 (November 23: §T6 the trial of the cheaper Gemini models of November 18 written down, the models our project can use, the mixes and their cost, and the joint review across models to come, open models on Modal among them). 0.5 (November 19: text_ is build_doc_ and the lists task build_glossary_, the template's decision 40; the default target makes the report, `make review` opens the pilot's page; decided, not built). 0.4 (November 19: the task keeps its own files, orgpedia/doc `docflow.md` §N9: its input linked a file each, its layers moved to `export/` by `make export`, Gemini's answers in `responses/`, the pinned lists in `input/data/`, §T2). 0.3 (November 18: how a GR is translated, step by step, §T3; a batch asks each sentence once and keeps each answer by sentence, §T4; what it costs, measured, §T5; cheaper models, proposed, §T6). 0.2 (November 17: the routes after a person's review of the pilot; the review page; names Gemini spelt kept). 0.1 (November 17, 2026: set up as a task of its own; the pilot first) · @Mukund

**Builds on:** the template's spec (`spec.md` §G3, decision 30), `orgpedia/doc` `specs/docflow.md` §P19 (a task's folder; a task over another's files) and §P11b (paid calls by batch), `specs/govdoc.md` §11.5 (layer files), `specs/mahgrs.md` Part L (translation by annotation: the routes, the memory, the glossary, the checks; its decisions log). The build_doc_ task's spec (`../build_doc_/spec.md`; text_ until November 19) says what it reads. The code: docflow's `tasks/glossary.py` (`glossary_tagger`), `tasks/translate.py` (`translate`, version 10) and `batch.py`.

## T1. What it does

It reads the GovDoc file build_doc_ made of each GR and adds the English: the names of the shared registry found in the text, then the translation of every block and table cell, with its checks. It writes none of build_doc_'s files.

| # | Step | Task | Writes |
|---|---|---|---|
| 1 | `import` | `import_govdoc` | nothing: the files are those linked in `input/govdoc/` |
| 2 | `glossary` | `glossary_tagger` | the registry's names, linked to their entries and their English; no model |
| 3 | `translate_en` | `translate` | English by routes (§T3); the model only for what nothing else serves, by batch; on the pilot list (`src/pilot.txt`) until the department's cost is agreed |

## T2. The folder

| | |
|---|---|
| `input/govdoc/` | a link a file to build_doc_'s `output/<name>.govdoc.json.zst` (a link to a link: the lineage), made by `make input` (`mahdept inputs`, orgpedia/doc `docflow.md` §N10) |
| `input/data/` | the registry and the memory the flow pins, a link a file to build_glossary_'s `output/` (`docflow.md` §N19) |
| `src/` | `flow.yml` (`storage: {layout: task}`), `prompts/translate_en.md`, `pilot.txt` (the department's own), `data/` (written: the profile) |
| `conf/` | a person's edits to translations, one file a GR; `values.yml` (written from `department.yml`, committed) |
| `output/` | `<name>.pdf.en.json.zst`: one layer a GR, a file of its own until `make export` moves it to the repo's `export/translate_/` and leaves a link; `<name>.pdf.status.json`, each GR's status record, in git. No joined file |
| `review/translate/` | the pilot's translations for a person to read (made by the default target; `make review` opens the page) |
| `responses` | a link to the repo's `export/translate_/responses/`: Gemini's answers, each sentence's under its own key, packed by month and pushed by `make push_hf` |
| `review/tmp/` | `defer.jsonl` (what waits for a batch), not committed |

## T3. How a GR is translated

**Before any model:**

1. **The GR** is read through the link to build_doc_'s output; this task keeps only its own layer.
2. **Names** (`glossary_tagger`, no model): every name of the department's pinned registry (offices, posts, departments, courts; each with its Marathi, other spellings and its English) is found word by word in every block and cell: spellings folded (`match_key`), only spaces and light punctuation (`, - ( ) / .`) between its words, a case ending allowed on its last word (`मुंबईतील`, `आयुक्तांना`, `विभागाच्या`); where names overlap the longer wins; a name of one word needs three letters; a head word marked `tag: false` (`अधिकारी`) is not looked for. Each is an entity linked to its entry.
3. **Units:** each in-flow block and each table cell. The layout makes the blocks: the decision's numbered paragraphs are usually blocks of their own; items of a list that the text layer put in one block stay one unit, except in a section read by line (the copy list), where each item is cut apart (step 4). List markers are coded (step 5) and written back.
4. **Sentences, by rule (no model):** a cut after `।`, or after `.` followed by a space (not after an abbreviation, a word of two letters or less: an initial, or a number like `४.२`); at each line end in a section read by line, and there where a list item starts a line; never inside a value or a name (`विसस- २२९३/प्र. क्र. १३९` is one order number).
5. **Codes:** each value (a date, amount, order number, list marker…) becomes `<V1>`, `<M1>`, written back after in its printed form (digits 0-9, the month in English, an order number's Devanagari digits kept); each name found is noted with its English.
6. **The free routes**, the first that serves:
   1. **The memory:** the department's pinned translation memory (sentences in 10 GRs or more over all departments, in placeholder form, translated once; built by `mahdept memory build`), found by a spelling-tolerant key.
   2. **The glossary:** a sentence that is one registry name (a copy list's entry, a cell).
   3. **A rule:** a sentence of values, digits and punctuation only.
   4. **The memory with the names as printed**, for a sentence bound for the model only: an entry saved before a name was in the registry (`महाराष्ट्राचे राज्यपाल यांच्या आदेशानुसार व नावाने`, saved before "महाराष्ट्राचे राज्यपाल" became `<N1>`).
   5. **A near entry:** one the memory has but for an OCR's slip (`महाराष्राचे` for `महाराष्ट्राचे`): 30 letters and 4 words or more, one or two words of 4 letters or more differing by two letters in all, no digit, code, anusvara or chandrabindu among the differences, one entry only. Marked for review.

**The model (by batch):**

7. **The call cache by sentence:** a sentence the model answered before (the same coded sentence, glossary line, model and instructions) takes its answer and is not sent. Unlike the memory, this is the department's own store, exact, and written as answers come.
8. **Requests:** the rest, in chunks of up to 80 sentences (`max_sentences`): the instructions (the prompt, about 1,500 characters), each sentence as `[j]` and its coded text, a `Glossary: <Marathi> = <English>; …` line under one with names. Each request also carries its sentences' cache keys (`pieces`), which the model never sees.
9. **Deferred:** `make flow` sets `DOCFLOW_DEFER`, so no request is sent; each is written once to `review/tmp/defer.jsonl` and the GR waits.
10. **`make count`** (free): the batch is made again (§T4) and its requests and input tokens counted, for the cost to be agreed.
11. **`make batch`** (paid): one Vertex AI batch job at half price; each answer is kept under its request's key and, sentence by sentence, under each sentence's key (§T4).
12. **`make flow` again:** each waiting GR finds its sentences answered in the call cache by sentence (step 7), whatever its chunks come out as now.
13. **Checks on each answer:** nothing back, an empty answer for a sentence with words, a code left out or one the sentence does not have. One that passes is used. One that failed in a chunk is asked again on its own, in the next batch. One that failed on its own is an issue (`core:translation_check_failed`) and gets no translation; it is kept, marked, so no later run pays for it again.
14. **Values written back**, the names' English kept as the registry gives it.
15. **Joined:** a unit's sentences with the source's line breaks between them; the English on the block or cell, in this task's layer.
16. **The report** (in the default target; `make report` alone runs it again): each sentence's route, the checks, build_doc_'s flags, for the review page (§T3b).

When build_doc_ runs again, a GR's translation runs again only if what it reads changed (a block's text, a value, a section, a name); the memory and the call cache answer what was translated before.

## T3a. The routes, as the pilot's review left them

The order and limits of §T3 step 6 come from a person's review of the pilot (`mahgrs.md` Part L, decisions 0.10). A copy list's entries are sentences of their own and keep a line break each in the English.

## T3b. The review page

The default target writes `review/translate/pilot.txt` and `pilot.json`, and `make review` opens the page in the browser (November 19, decision 40; not built); the page shows one block at a time, only those to review: a sentence the model translated or a near entry served, a check that failed, or build_doc_'s flags on the block (broken characters, a block cut in two, lines run together, a table to check). A person marks each good or needing a fix, with a note.

## T3c. Names Gemini spelt

`mahdept glossary names` lists the signatories Gemini spelt that the glossary sheet lacks (`review/glossary/names.tsv`); with `--add` they become draft rows of the sheet, for the next registry (`mahdept glossary compile`), so a later GR spells them alike.

## T4. Nothing asked twice (November 18, translate 10)

* **Each sentence once in a batch:** before a batch is counted or sent, its translate requests are made again (`_pack`, docflow's batch packer, `docflow.md` §P11b): each sentence once over all the GRs that asked it, none the call cache already answers, a sentence asked on its own (a retry) still on its own, the rest in chunks as large as the largest asked. Requests of other settings (another model, other instructions) are kept apart.
* **Each answer kept by sentence:** as the job's answers are taken in, each sentence's English is kept under its own key (`_split`, the batch's splitter), passing or not (a failure marked). Before, an answer was kept only under its whole request's key and reached the sentences only when a later run made exactly that request again.
* **Why:** in the pilot of November 17 the code changed four times between batches (translate 6 to 9), each change made other chunks, and 1,321 sentences already answered were sent again (batches 2 to 5: 790, 335, 162 and 34), about $0.18 of the pilot's $0.35; the first batch also sent 165 sentences twice, asked by several GRs (13%). On the pilots' waiting batches the change made PWD's 5 requests 4 (3,293 input tokens to 2,913) and Finance's 10 requests 3 (8,855 to 6,208).
* **Across departments** the memory serves, after it is built again with the new departments' sentences (`mahdept memory build`); one department's call cache is not read by another.

## T5. What it costs (measured, November 18)

* **Per GR:** the PWD pilot's first batch (its 50 GRs once over, 1,116 sentences: 92,683 tokens in, 64,310 out) at Gemini 3.8 Flash's batch price ($0.375 and $1.875 a million tokens until December 31, 2026) is about $0.0031 a GR, about $0.0033 with the sentences the later batches added. Output is three quarters of it.
* **What is sent:** of the pilot's 1,203 sentences for the model, half are of 10 words or fewer (headings, entries, cells) and a quarter of 20 words or more, which carry 60% of the text; two thirds carry codes and over half a glossary line, so a model must follow the prompt (only 18% are plain text).
* **All departments** (the crawler's records to February 5, 2026; GRs over 25 pages left out; Cloud Vision at about $1.50 a thousand pages for the 2–8% of pages a text layer cannot give, measured on PWD and Finance):

| | GRs | Gemini 3.8 Flash, by batch | Cloud Vision |
|---|--:|--:|--:|
| From January 1, 2019 | 96,020 | about $320 | about $27 |
| From January 1, 2024 | 38,399 | about $130 | about $11 |
| Before 2019 | 76,190 | about $250 | (as build_doc_ reads them) |

  Gemini 3.8 Flash's price doubles on January 1, 2027: what stays on it is best sent before. Public Works from 2019: 3,075 GRs, about $10; Finance: 1,393, about $5.

## T6. Cheaper models (tried November 18; a joint review across models to come)

**Prices by batch** (a million tokens, in / out; Vertex AI, checked November 18): 3.8 Flash $0.375 / $1.875 (twice from January 1, 2027: $0.75 / $3.75); 3.5 Flash-Lite $0.15 / $1.25; 3.1 Flash-Lite $0.125 / $0.75; 3 Flash (preview) $0.25 / $1.50; Gemini 4 models $0.75–2.00 / $3.75–10.00. Thinking is billed as output.

**What our Vertex project can use** (checked November 18 with a free token count, in the two regions tried): 3.1 Flash-Lite, 3.5 Flash-Lite, 3 Flash (preview), 3.6 and 3.8 Flash, the Gemini 4 models. **Not available to us:** 2.5 Flash-Lite (404 `NOT_FOUND` for `gemini-2.5-flash-lite` and `gemini-2.5-flash-lite-001`, in both regions; it seems to be offered only through the separate Gemini API of AI Studio, another key and another billing), 2.0 and 2.5 Flash and Flash-Lite, Gemma 4. So 3.1 Flash-Lite is the cheapest Gemini model we can use; the $0.05 / $0.20 of 2.5 Flash-Lite is out of reach.

**The trial** (November 18, by batch, about $0.23 in all): the 1,250 distinct sentences PWD's 50 pilot GRs sent to the model, each model given exactly what 3.8 Flash was given (the same coded sentences, glossary lines, instructions and chunks); 3.8 Flash's answers, reviewed by the person on November 17, the baseline. The checks are translate's own (§T3: an empty answer, a code lost or added) and the review page's (a glossary name not used, digits that differ from Flash's, Marathi left); closeness to Flash is a similarity of the two English sentences, from 0 to 1, put in three bands (same or nearly, close, far; the trial's script and its thresholds did not survive, below).

| | 3.1 Flash-Lite, thinking low | **3.1 Flash-Lite, thinking minimal** | 3.5 Flash-Lite (no thinking) |
|---|--:|--:|--:|
| Fails any check | 2.6% | **3.4%** | 4.6% |
| … a code lost, or an empty answer | 0.3% | 1.2% | 1.0% |
| … a glossary name not used | 0.8% | 1.1% | 2.2% |
| … digits differ from Flash's | 0.8% | 0.4% | 0.6% |
| Same as Flash, or nearly | 35% | | 29% |
| Close to Flash | 47% | | 51% |
| Same, nearly or close | 82% | **83%** | 80% |
| Far from Flash | 3.4% | 3.9% | 4.2% |
| Thinking tokens | 41,621 | **0** | 0 |
| Batch cost | $0.084 | **$0.056** | $0.082 |
| With the failures sent on to 3.8 Flash | $0.088 | **$0.062** | $0.090 |
| Share of 3.8 Flash's cost for the same sentences (about $0.146) | ~60% | **~42%** | ~62% |

* **3.1 is better than 3.5,** though 3.5 is the newer: fewer failures and more answers the same as Flash's.
* **The saving is about 40–60%, not the three to nine times the price list suggests:** 3.1 thinks at "low" (41,621 thinking tokens on 58,000 of answer, billed as output); at "minimal" (the 3.x models have no setting that turns thinking off) it thinks not at all, and loses a little, mostly in codes (1.2% of answers lose one against 0.3%), which is exactly what the checks catch and send on.
* **Length barely matters:** closeness to Flash is about 0.87–0.90 at every length. Long sentences fail a little more often: with thinking low, 4.3% at 40 words and over against 2.3% under 10; with thinking minimal, 5.9% at 20–39 words against 3.4% overall.
* **After January 1, 2027,** when 3.8 Flash's price doubles and the Lite models' do not, Lite with its failures sent on is under 30% of Flash.

**The mixes, for every department's GRs from 2019** (96,020 GRs; short sentences on 3.1 Flash-Lite at minimal thinking, the long ones and every failure on 3.8 Flash):

| Long sentences from | Sent to Flash | Share of the text | Now | After January 1, 2027 |
|---|--:|--:|--:|--:|
| (all on 3.8 Flash, as the flow is) | 100% | 100% | ~$320 | ~$635 |
| 20 words | 24% of sentences | 57% | ~$240 | ~$420 |
| 40 words | 6% of sentences | 23% | ~$175 | ~$250 |
| (all on 3.1 Flash-Lite, the failures to Flash) | ~3% | | **~$130** | **~$135** |

Long sentences hold most of the text, so sending them to Flash keeps most of the cost; the trial did not show Lite worse on them. For the 120,974 GRs whose PDFs are all text (`mahgrs.md` §W16, November 23): about $165 on Lite with the failures sent on, against about $400 all on Flash (about $170 against $800 after January 1).

**Not decided.** A review page (`review/compare/flash-lite.html`) showed 50 sentences where a Lite answer failed a check or read otherwise than Flash's, for the person to mark; no marks were recorded and no model was chosen. The trial's files did not survive (the scratchpad was cleared and PWD's repo made again): the test set is made again from PWD's pilot (its translate_ step run with `DOCFLOW_DEFER`, which writes every request; 3.8 Flash's answers from its `responses/`).

**The joint review** (the person's, November 23): the same sentences through every candidate, side by side for a person to read, with the checks counted for each: 3.8 Flash (the baseline), 3.1 Flash-Lite at minimal thinking, 3.5 Flash-Lite, and the open models served on Modal by our own translation service (`mahgrs.md` §L14), each with its cost per 1,000 sentences. A change of model is then one line of `flow.yml` (`provider:`, `model:`); the prompt, codes, glossary and call cache stay.

**Open models.** A model fine-tuned for Indic translation with a fixed prompt (IndicTrans2; Bodhan AI's Indic Translate) cannot take the codes and the glossary, so it could serve only the plain sentences (about 18%); a general open model that follows the instructions can serve all, for GPU hours, at a quality the joint review measures.

## T7. Not built yet

* ~~The status records and packing the layers for the dataset~~ (November 19: `make export`, `make push_hf`; `docflow.md` §N12–§N14).
* Samples for `make check`.
* The reviewer on this task's files.
* Escalating a cheap model's failures to a stronger one (§T6).
