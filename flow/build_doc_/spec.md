# build_doc_: from a GR's PDF to its GovDoc File

(Named `text_` until November 19: the template's decision 40. The folder is renamed with the release; the names in the version notes and decisions below are those of their day.)

**Version:** 0.13 (November 23: text PDFs first: no batch round or later text pass when nothing was deferred; `ocr: none`). 0.12 (November 21: `input/` holds only what the task reads, its PDFs, `sources.json` and the other departments' scorecards, no infos and no lists; the flow pins only the profiles, `${profiles}`; `docflow.md` §N27 rules 9 and 10). 0.11 (November 20: the pages read whole by IndicOCR (Bodhan AI, on our gateway), its words on Tesseract's boxes, by batch; the boxes by Tesseract; Cloud Vision for the pages IndicOCR is doubtful on, within the department's `cloud_vision_budget`, the newest GRs first (`mahdept ocr pick`); `make flow` in five steps; §X2c, §X4, decision 14; orgpedia/doc `docflow.md` §T5, `mahgrs.md` §W16). 0.10 (November 19: renamed build_doc_; its default target makes all the tasks after it read, the set-aside list in `output/set_aside.txt`, the glossary's candidates no longer made here; `make review` opens Studio at the scorecard; the scorecard's counts beside its shares; §X1, §X7a; decided, not built). 0.9 (November 19: the task keeps its own files, orgpedia/doc `docflow.md` §N9; no export step, each GR's export made from its GovDoc file when a report asks, step 14). 0.8 (November 17: broken characters of every kind, step 3; the copy list under "प्रत सहपत्रासह,", step 9; lists in blocks no section holds, step 10; blocks to look at, flagged, step 12, §X5; decision 13). 0.7 (proposed; November 17: the names found and the English are the `translate_` task's, decision 12; text_ makes no model call but Cloud Vision's). 0.6 (November 15: the patterns' tests, `src/patterns_test.yml`, §X7; a signature's note of what it encloses no longer starts an annexure when its block is short, decision 11; the reading settings fixed once the samples are confirmed, §X2c, decision 10; the broken reph a warning, the batch issue not built, §X5; the samples in `src/expected/`, §X1. 0.5, November 14: setting the missing fields in the reviewer's queue, §X7; the copy list's numbered entries, annexures at a table or at a title naming the GR, the order line after a dash, the references under "पहावे", §X2 step 9; the portal's date, GR code and title where the text has none, §X2 step 15, §X6; the scorecard counts what the text gave, §X7. 0.4: kept in the template, the one copy, since November 14: every change to text_ is made here with its code, and reaches each department by `copier update`; translation stays in text_; ruled tables on scans, §X2a; the department's values from a file, §X3; scans read last, a scan drawn over a scanner's text read by OCR, §X2c; the scorecard, §X7) · **Date:** November 14, 2026 · @Mukund

**Builds on:** the template's spec (`orgpedia/template.mahdept`, `spec.md`: the list `import/pdfs.txt`, the make targets, the JSON output §G5, promotion §G10), orgpedia/doc `specs/docflow.md` (the runner; Part D sections, Part T `pdf_text`), `specs/govdoc.md` (the format). Why each step is as it is, and what Finance taught, is in orgpedia/doc `specs/mahgrs.md` Parts F (the Finance GRs) and L (translation). Sections are numbered §X1, §X2…

build_doc_ is the core task: it reads every GR's PDF once, at most at the cost of Cloud Vision for its scans, and writes its GovDoc file: the words, lines, blocks and tables, the GR as one document, its sections, and the names and values in it. Every other task starts from these GovDoc files (on HuggingFace, `govdocs/<dept>/<YYYY-MM>.tar`), not from the PDFs.

---

## X1. What it reads and writes

* **Reads:** the PDFs of the GRs in `import/pdfs.txt`, through links in `flow/build_doc_/input/` (`make import`); the portal's record of each, `input/sources.json` (the import step, the scorecard and `make repeats`); the other departments' scorecards, `input/scorecards/`. Nothing else is linked into `input/` (`docflow.md` §N27 rules 9 and 10, November 21): not the crawler's records (they stay in `import/infos/`, where `make import` makes `sources.json` from them) and not the lists (no step here reads the registry or the memory; `translate_` links them).
* **Leaves out:** GRs of more than `max_pages` pages (20; `mahgrs.md` §F16), and the GRs in `output/set_aside.txt` (the rules' and a person's rows from `conf/set_aside.txt`, each with its reason; Finance's lottery GRs; template §G4a). Their JSON says `skipped` and why.
* **Writes:** a GovDoc file a GR, `output/<name>.govdoc.json.zst`, a file of its own until `make export` moves it to the repo's `export/build_doc_/` and leaves a link; and a status record a GR, `output/<name>.status.json`, in git (orgpedia/doc `docflow.md` §N9, §N14; the template's spec §G5).
* **Its folder:** `flow/build_doc_/` holds `spec.md` (this file, kept with the task), `src/flow.yml` and its prompts (the code is the `mahdept` and `docflow` commands, template spec §G1a; the department's own values put in from `conf/values.yml`, written from `department.yml`, template spec §G2), `conf/` (the reviewer's edits, and `values.yml`), `review/`, `src/expected/` (the samples), `README.md` (the issues); `input/` (links to the PDFs, the portal's records) and `output/` (each GR's status record and its GovDoc file's link into the repo's `export/build_doc_/`), committed as links and records (orgpedia/doc `docflow.md` §N9; November 19); `cache/`, `review/tmp/`, `logs/` not committed.

## X2. The steps

| # | Step | `docflow` task | What it does |
|---|---|---|---|
| 1 | `import` | `import_manifest` | the PDFs of the list, each once by its hash |
| 2 | `text` | `pdf_text` | the text layer through unipdf (Unicode for Devanagari fonts); scanned pages, legacy fonts and invisible text by OCR: a page whole by IndicOCR on Tesseract's boxes (by batch), its boxes alone by Tesseract; a page that lost its reph, and a scan drawn over a scanner's own text, by OCR; the doubtful pages by Cloud Vision within the budget, read last (§X2c) |
| 3 | `build_doc_check` | `deva_check` | Devanagari words the text layer gave wrongly, page by page: a vowel sign first (" ोबतचे"), and what a wrong font map leaves, another script's letters ("ী"), a legacy font's marks ("¨"), a Symbol font's private-use bullet (docflow Part T) |
| 4 | `lines` | `ruled_lines` | lines that stop at a table's rules |
| 5 | `layout` | `pdftable_finder` | the tables, with paragraphs, headings and the pages' furniture around them (running heads and feet, "please turn over" (कृ.मा.प.), the Government Press's form codes); a list marker or a section heading starts a paragraph; on a scanned page, the ruled tables in its image (§X2a) |
| 6 | `tables` | `pdftable_cells` | each table's cells |
| 7 | `table_check` | `ruled_table_check` | tables the three steps found differently |
| 8 | `split` | `section_splitter` | the GR as one document (annexures in it), its id from the GR code it prints, else its URL |
| 9 | `roles` | `pattern_tagger` | the GR's sections, every block in exactly one, in the order a GR prints them: subject, masthead, references, preamble, decision, signature, copy list, annexures; an English GR after the Marathi one starts afresh. The references under "संदर्भ", "वाचा", "पहा" or "पहावे" (PWD's, 716 GRs). The order line in its forms ("शासन निर्णय क्रमांक …", "शासन निर्णय - बीडीजी-२०१०/…", "शासन निर्णय. वित्त विभाग क्रमांक …", "Circular No. 2017/C.R.112"); a numbered entry of the copy list, however long, stays in it; the copy list under "प्रत सहपत्रासह," or "प्रत गोषवा-यासह," (with the enclosures, the summary: PWD, 49 GRs of 2007-2010 whose copy list was read as the decision's) or "प्रत." too; an annexure starts at its heading, at a table (its heading often its first row), or at a title naming the GR's number and date with more after it ("… दि. … सोबतचे परिशिष्ट"; a running header ends at its date); a heading on two blocks is one annexure (docflow Part D 0.2) |
| 10 | `lists` | `list_finder` | numbered, lettered and bulleted lists in running text, in the blocks no section holds too (an old scan's "क) … ख)") |
| 11 | `role_check` | `pattern_check` | the sections a GR must have (subject, masthead, references, preamble, decision…), and the fields (order kind, order number, date, GR code); a missing order kind or number is set by a person from the reviewer's queue (§X7) |
| 12 | `block_check` | `block_check` | blocks to look at before their text is trusted, flagged and never changed: a sentence cut in two by the layout, lines ending in commas read as one paragraph outside the copy list, a table hard to be sure of or text that looks like a table not found (docflow Part D §D5a) |
| 13 | `values` | `value_tagger` | dates, amounts, percentages, financial years, identifiers, pay scales, budget heads, parts of a document, contact details |
| 14 | (no step) | | each GR's export (each document's fields, parts, text and tables, `studio.md` §S5; where the text gives no issue date or GR code, the portal's, and the portal's English title, §X6) is made from its GovDoc file when a report asks (`mahdept.exports`, kept in `review/tmp/exports/`); the `json_export` step and its `output/<name>.pdf.json` were dropped November 19 (`docflow.md` §N16 item 7) |

### X2a. Ruled tables on scanned pages

A scan has no drawn rules, so step 5 finds a scanned page's ruled tables in its image (orgpedia/doc `docflow.tasks.scantables`), set by `scans: true` in the table settings (docflow's default is off; build_doc_'s flow sets it). On November 12 the code called 1,519 of Finance's 6,892 scanned pages ruled (680 GRs); a person's check of 30 found 25 right, 2 partly and 3 wrong.

1. **The rules:** long thin straight runs of ink in the page image (150 dpi), small gaps bridged; not strokes inside OCR's word boxes (a Devanagari word's headline), not filled areas (a photo, a scan's black border). A table drawn without its outer lines is closed where three or more rules start or end together.
2. **Straightened:** the page's tilt is measured from its long rules, and the rules and OCR's word boxes are turned by it (not the image), so a table's rows and columns are counted rightly.
3. **The cells:** the rules go to the same table finder as a text PDF's drawing (`ruling.find_tables`), and each OCR word goes into the cell its middle lies in; the table is written as a text PDF's is, and steps 6–7 read it the same way.
4. **Kept only if it looks like a table:** at least two columns and two rows, and words in enough of its cells; otherwise the page stays paragraphs, with the issue `scan_table_unstructured`.
5. **No text lost:** a word in no cell stays in the paragraphs around the table.

Tables without rules on scans are not looked for: the code's calls (from rows of pieces lined up) were mostly wrong on the check, taking a copy list or a signature block for a table (§X8).

### X2b. Settings

Settings are for the whole department, never for one GR. Mistakes are found by the checks (steps 3, 7, 11) and fixed by a person in the reviewer, recorded as edits in `conf/` (edits only, never settings). A difficult GR goes in the flow's `exclude`, with a reason.

### X2c. Reading the text: what goes to Cloud Vision, and when

Step 2 takes a page's text from its text layer when it can, and reads the page (or the boxes it cannot read) by OCR when (`ocr: indic`, November 20: a page whole by IndicOCR, its words on Tesseract's boxes; boxes by Tesseract; Finance, Public Works and Parliamentary Affairs were read by Cloud Vision, `ocr: gcv`):

| The page | Read by OCR |
|---|---|
| has no text layer (a scan) | the whole page |
| has words in a legacy font, or fonts unipdf cannot convert | the whole page when they are 90% of its words, else their boxes |
| has invisible text (a scanner's OCR layer, render mode 3) | the same (`hidden: ocr`) |
| has text painted over by an image covering the page (a scan drawn over the scanner's OCR, the text in an ordinary render mode; PWD's GRs of 2001–2013, `~q:q ftttjonfl…`) | the whole page, the text under it left (`covered: ocr`, November 14; docflow Part T) |
| lost its reph in the text layer | the whole page (`reph: ocr`) |

* **IndicOCR by batch, then Cloud Vision on a budget** (November 20; `mahgrs.md` §W16): `make flow` runs the text step with IndicOCR's requests deferred (`logs/deferred.jsonl`), sends them to the gateway (`docflow batch`; paid, about $0.0004 a page, without a stop, but it stops `make` when the gateway is out of money), runs the step again (twice: a page with a block cut off is asked again at 6,144 tokens), then `mahdept ocr pick` names the pages IndicOCR is doubtful on (its words agree with Tesseract's on under 0.6, or a block was cut off) that Cloud Vision reads, within `cloud_vision_budget` (`department.yml`), the newest GRs first, in `conf/overrides/text/<file_id>.yml` (in git; pages added, never taken out), and the whole flow runs. `logs/info.pick.log` says what was chosen, its cost, what is left of the budget and the doubtful pages left out, by year. The page images wait in `logs/deferred.jsonl.files/` (the repo's `make clean_images` removes them); `make import` and `make flow` refuse while the repo has no `import/pdfs.txt` (after the repo's `make clean_pdfs`: November 21).
* **Text PDFs first** (November 23; `mahgrs.md` §W17; the template's decision 44): with `make list_text_all` (only the GRs whose PDF is all text) and `ocr: none` (no OCR, nothing paid), the first text pass defers nothing, and `make flow` skips its batch rounds and its second and third text passes; a text page whose text layer lost its reph keeps it, `core:text_broken_reph` flagged.
* **Each page is paid for once:** IndicOCR's and Cloud Vision's answers are kept in `responses/` (a link to the repo's `export/build_doc_/responses/`), packed by month by `make push_hf` (`responses/<dept>/build_doc_/<YYYY-MM>.zip` on the dataset) and taken out again by `make import`.
* **Scans last** (`context.later: [gcv]`, docflow §P11a): a run's first pass finishes every GR whose pages need no new Cloud Vision answer; the GRs that do are read in a second pass.
* **A passing failure is tried again** (`context.retries: 3`): Cloud Vision unavailable for a moment (a 503) does not fail the GR.
* **The reading settings are fixed once the department's samples are confirmed** (`ocr`, `languages`, `reph`, `covered`; November 15): a change to them reads every GR again, and a GR with a person's edits is then held until it is reset, its edits lost (`--allow-reset`, docflow §P16). A page that needs reading another way later gets a new step that applies to those pages only, not a change to these settings.
* **To count before paying:** `DOCFLOW_CACHE_ONLY=gcv,gemini make flow` calls nothing; the GRs that fail with `CacheOnly` are the ones that need Cloud Vision.

## X3. What differs between departments

`src/flow.yml` is the same file in every department (template §G2). What is a department's own is in its `department.yml`, rendered from its entry in the template's `depts.yml` (template decision 36), `null` until decided; `mahdept values` writes the flow's values from it into `conf/values.yml` (committed) before every docflow command, and the flow puts them in when it loads (`values: ../conf/values.yml`; docflow §P4a). A value not decided stops the flow.

| In `department.yml` | In the flow |
|---|---|
| `masthead.names` (every name the masthead's department line has had, newest first) | `${masthead_names}`: step 9's masthead patterns ("महाराष्ट्र शासन <department>", the department line alone, the order line after it); `${masthead_words}`: the decision heading's lookahead (a reference's "शासन निर्णय <department>…" is not the decision). `[]`: patterns that match nothing (`(?!)`), the rest of the flow unchanged |
| `data.profiles` (the profiles' version) | `${profiles}`: the flow's one pinned outside data (the registry and the memory are `translate_`'s; no step here reads them) |
| `max_pages`, `set_aside.rules` | not in the flow: which PDFs `make import` links into `input/`, which GRs the reports and lists leave out |
| the pilot list (`src/pilot.txt`) | step 14's `applies_to`: the department's own pilot, chosen when it is started (`mahgrs.md` §W4 step 9) |

The rest of the flow is the same for every department: it describes Maharashtra's GRs, not one department's. `mahdept check` (in `make check`) says whether every value is decided, `values.yml` agrees with `department.yml`, and the flow names no department.

## X4. What it costs

* **IndicOCR** (step 2): the pages read whole, by batch, about $0.0004 a page and $0.05 a batch: a few dollars a department. **Cloud Vision**: the doubtful pages, up to `cloud_vision_budget` (`mahgrs.md` §W11, §W16). Each page is paid for once: its answer is in the call cache, and the cache travels with the month (`runs/`).
* **Gemini** (step 14): by batch only (`mahgrs.md` §W7e), about $5 a 1,000 GRs; less as the memory grows.
* Every other step is free. Running build_doc_ again on a month whose `runs/` were pulled costs nothing.

## X5. Issues it reports

Each step's issues go into the GovDoc file (and `logs/info.issues.tsv`, not committed); each GR's status record counts them by code, and `make export` writes the counts over all GRs into the task's `README.md` and `review/issue_counts.html`. The common ones:

| Code | Severity | Means |
|---|---|---|
| `core:build_doc_by_ocr` | info | a page, or its boxes, read by Cloud Vision, and why (§X2c) |
| `core:build_doc_broken_reph` | warning | a page lost its reph in the text layer, read by OCR |
| `core:section_inferred` | info | a section found without its heading |
| `core:build_doc_suspect` | info, warning | a page's words broken by the text layer or the OCR, listed (a warning when 1% of its Devanagari words or more) |
| `core:block_unfinished` | info | a block of running text ending mid-sentence, the next of its section going on (step 12) |
| `core:lines_run_together` | info | a block of lines ending in commas read as one paragraph, outside the copy list (step 12) |
| `core:table_review` | info | a table to check (merged cells under a header of several rows, many empty cells, read by OCR) or text that looks like a table (step 12) |
| `core:role_missing` | warning | a field not found: order kind, order number, date, GR code |
| `core:awaiting_batch` | info | a step waits for a model batch (not built: with the daily runs, `mahgrs.md` §W7e; today the step fails for the GR with "deferred to a batch" until `docflow batch` has run) |
| `core:scan_table_unstructured` | info | a scanned page where a ruled table may be but none was kept (§X2a step 4) |
| `unipdf:unconverted_char` | warning | characters in the text layer unipdf could not convert, kept as given |

## X6. Its status record

Each GR's status record is `output/<name>.status.json`, in git, written by docflow (`docflow.md` §N14; the template's §G5, November 19; it replaces the JSON record of November 12 in `export/build_doc_/<YYYY-MM>/`): its source PDF and hash; its status (`done`, `failed` with the step and reason, `waiting`, `skipped` for a PDF over `max_pages`, with its page count); its issues by code; each step's version; its GovDoc file's place in `export/build_doc_/`, hash, size and revision; and docflow's state. Not yet in it: the pages from the text layer and by OCR (the scorecard counts them).

Step 15's full JSON (fields, parts, text) holds, where the GR's text gives no issue date or GR code, the portal's (its record in `input/sources.json`, a link to `import/src/`), marked `"from": "listing"` and with no words, and for every GR the portal's English title (`portal_title`); a reader that wants only what was read leaves out the fields marked so. It is not kept since November 19: the reports make it from the GovDoc file (`mahdept.exports`, the same `export_file` as `json_export`, the portal's record from `input/sources.json`), checked identical to `json_export`'s on PWD's 50 pilot GRs; `make check` runs the samples on it (`mahdept expect`).

## X7. Its samples and its scorecard

* **The scorecard** (`mahdept report scorecard`, template §G11a): how the department's results look, by year group beside other departments' (their `scorecard.json`, pushed to the dataset by each and linked into `input/scorecards/`, `docflow.md` §N19; `--against <file>` for another), without a model or a person reading them: text (scans, OCR, characters not converted), fields and sections missing, sections found without their heading, tables; and two truths for every GR, the issue date and the GR code read against the portal's. It counts what the GR's text gave, not the fields the export took from the portal (one more line counts the GRs with no date even from the portal). It flags a measure 5 points worse or more and lists the GRs behind it, so the cause is found by code and counts. On November 13–14 it found PWD's scans drawn over a scanner's text (§X2c) and a numbered list of offices taken for an annexure. Since November 17 it also writes `review/setup/scorecard.html` (`make scorecard`, in `make all`): the run's completeness, what must hold before committing, the measures beside every other department's and the last scorecard's, step 12's flags, and the GRs to look at first (template §G11a). Every issue code is described in `review/issues.html`, grouped by the step that raises it: Studio shows a code's description under the issue ("What this means"), and the scorecard lists every code by step, with its GRs, its share beside the other departments' and the description's first paragraph.
* **Setting the missing fields** (November 14): the order kind or number a GR's text does not give the flow (old GRs, letters, Gazette pages, scans: PWD's 171 and 50, in 173 GRs) is set by a person in the reviewer, not by more patterns (§X9 decision 9).
  1. **The queue** (`review/studio.yml`, `queue: {codes: [core:role_missing], labels: [gr:order_kind, gr:order_number]}`; `make studio`, `studio.md` §R3.1): "Missing fields: 173 to do" opens each GR with the field form ready for its first missing field; the person clicks its words in order ("शासन", "निर्णय"; a number split over two lines) and presses `Enter`, then the next missing field; or dismisses it with a note (`x`: "no number printed"). The next GR opens when none is left.
  2. **Only words and fields are fixed** (`fixes: [words, fields]`): a misread word can be typed right, a field set or corrected; sections are not moved by hand.
  3. **Kept as edits** in `conf/<file>.edits.yml`, committed with the repo; the next `make flow` brings them in, so the field is the person's and the issue is gone. The export takes a person's field over the portal's.

  A key and a few clicks a field: under an hour for PWD. The issue date and GR code are not in the queue: the export gives the portal's (§X6). Suggested values with each issue (a number shaped like one on the first two pages, the kinds to pick from) are left for later.
* **The patterns' tests** (`src/patterns_test.yml`, November 15; docflow §P24): for the sections' headings and the fields' patterns, lines they must match, what they must read, and lines they must not match, taken from the GRs that showed each need. `make check` runs them first. A pattern is changed together with a line added there.
* **The samples:** `src/expected/` holds 10–20 of the department's GRs, across years and kinds of file (text layer, scan, legacy font, with a table), with what a person confirmed: the order number, the date, the GR code, the sections found. The scorecard picks them (`review/setup/samples.tsv`) for the person to mark. `make check` runs them; they cost nothing (cached).

## X7a. Its targets (November 19, template decision 40; decided, not built)

* **`make`** (the default, and what the top `make flow` runs): `make input`, the import, the flow, then the reports the tasks after it and a person read: the set-aside list (`output/set_aside.txt`), the tables' columns (`review/tables/columns.tsv`), the issues and the scorecard. The glossary's candidates (the officers who sign, the table cells, the copy lists) are build_glossary_'s, made there from these GovDoc files. `make repeats`, `make tables`, `make issues` and `make scorecard` stay, to run one again.
* **`make review`:** Studio on the GovDoc files in `output/`, opened in the browser at `review/setup/scorecard.html`; each cell and issue there opens its GRs. Nothing is run.
* **The scorecard's cells:** each measure's count and its share, `15 (7.7%)`, under a first line of the totals by year group (GRs, pages, pages read by OCR); each measure says what it is a share of (GRs, pages, the GRs where the field was read).

## X8. Open

1. **Step 15's JSON:** kept in text_, or moved to the task that needs it.
2. **GRs of more than 20 pages:** left out until decided otherwise (`mahgrs.md` §W12).
3. **Tables without rules on scanned pages:** not looked for (§X2a); a model by batch if they are ever needed.
4. ~~**Furniture patterns** for step 5~~: done November 12–13 ("please turn over" (कृ.मा.प.), the Government Press's form codes).
5. **PWD's problems** (`mahpwd/flow/text_/review/setup/problems.md`): ~~the copy list ending at a long numbered entry, the rest taken for an annexure~~ (490 GRs) and ~~annexure titles in a table or naming the GR, taken for annexures without a heading~~ (not second orders, as first thought): done November 14 (step 9). Open: GRs before 2010 with their order kind or number missing (letters, Gazette pages, scans), to be set by a person in the reviewer, not by more patterns (§X9 decision 9).

## X9. Decisions

1. **text_ is the core task;** every other task reads its GovDoc files, not the PDFs (Nov 11).
2. ~~**Finance is text_'s test bed**, this spec kept there and promoted after each change~~ (Nov 11; copied first on Nov 12). Replaced by 6.
3. **Only the masthead names, the pinned data, the page limit, the set-aside rules and the pilot list differ between departments** (Nov 11); in `department.yml`, the flow the same file everywhere, its values from a file written from it (§X3; Nov 13).
4. ~~**Translation stays inside text_ for now**~~ (Nov 11; replaced by 12 on Nov 17). Logically it is a task of its own (`translate_`, reading text_'s GovDoc files like any other task, leaving text_ with no model at all). But a task of its own writes its own GovDoc file for every GR, a second copy of each (`govdocs/` again, with English added), on disk and on HuggingFace. Until a task can add to text_'s GovDoc file without copying it, translation is step 14 of text_.
5. **Ruled tables on scanned pages, by code, no model;** tables without rules left out (§X2a) (Nov 12).
6. **This spec is kept in the template, the one copy** (Nov 14): every text_ change since November 13 was made in the template first (the values file, scans last, retries, `covered: ocr`), and a department, Finance too, takes the folder by `copier update`. A change to text_ is made here, with its code, in one commit.
7. **A scan drawn over a scanner's own text is read by OCR** (`covered: ocr`, §X2c) (Nov 14).
8. **The portal's values fill the gaps in the export, not in the GovDoc file** (Nov 14): the GovDoc file holds what was read, each value on its words; the export adds the portal's date and GR code where none was read, marked `"from": "listing"`, and the portal's title. The scorecard keeps measuring what was read.
9. **Patterns for what repeats, a person for the rest** (Nov 14): a cause seen in 20 GRs or more, or likely in other departments, is fixed in the flow; a field missing in a handful of GRs of one kind (letters, Gazette pages, old scans) is set by a person in the reviewer (`studio.md`, a queue of documents missing fields: planned), recorded in `conf/`.
10. **The reading settings are fixed once the samples are confirmed** (Nov 15): a later need is met by a new step on the pages it concerns, so no GR with a person's edits is reset (§X2c).
11. **A signature's note of what it encloses is not an annexure, in a short block too** (Nov 15): "सहपत्र - विवरणपत्र", "सहपत्र :- परिशिष्ट" were kept out by the annexure's own pattern but let in by the one for headings the text layer spaces out ("स ह प त्र"), which also matched the word unspaced; it now matches only the spaced forms. Found by the first run of the patterns' tests; tried on both departments before the change (`docflow trial`): PWD 46 GRs (41 annexures fewer, the copy list after the note found in 50), Finance 108 (81 fewer, 51 copy lists found).
12. **The names found and the English are `translate_`'s** (Nov 17): the `glossary` and `translate_en` steps left this flow for the task after it (`../translate_/`), which reads this task's GovDoc files through a link and keeps a layer of its own, not a second copy (`orgpedia/doc` `specs/docflow.md` §P19, `specs/govdoc.md` §11.5: what decision 4 waited for). The export no longer waits for the names. A GovDoc file made before this keeps the old steps' output until its text is read again; `translate_` leaves it out.
13. **What a person's review of the translation found is fixed where it starts, without disturbing the GRs that read well** (Nov 17, from a 2007 PWD scan in the pilot): the copy list's heading with its enclosures, lists in blocks no section holds, every broken character found; and what cannot be fixed safely by rule is flagged, not changed (`block_check`). Measured on 600 GRs of each department first (docflow Part D §D5a); the rerun's changes counted against the GRs before it, by year.
14. **IndicOCR for the pages read whole, Cloud Vision only on a budget** (Nov 20; `mahgrs.md` §W16, `docflow.md` §T5): about a quarter of Cloud Vision's price, better than Tesseract on every era but the 2020–2024 English tables; Cloud Vision reads the pages it is doubtful on, newest first, within the department's budget, never by itself when the two readings disagree. The pages are named for one GR in an override file by `mahdept ocr pick`, never by hand (the one exception to decision 3's "nothing for one GR").
