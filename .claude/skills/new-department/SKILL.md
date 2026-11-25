---
name: new-department
description: Set up this Maharashtra department's repo end to end, the same way every department is set up — get its GRs, find its own values (masthead names, GRs to set aside), run build_doc_, check sections and fields, build its glossary and memory reusing other departments' translations, a pilot translation, its samples, and a status note — stopping for the person at each decision and before anything that costs money. Use when the person says to set up, start, onboard or study this department.
---

# Setting up a department

This repo was made from `orgpedia/template.mahdept` (its `spec.md`; each task's own in `flow/<task>/spec.md`). Its tasks, in order: `build_doc_` (PDF to GovDoc file), `build_glossary_` (the department's glossary and memory), `translate_`. `make flow` runs them all, each making everything the next reads; `make review` (`TASK=<task>`) opens what a person reviews in the browser. Finance (`mahfin`) was the first department; every later one is set up by these steps, so they come out alike. Work through them in order. Write everything you find to `review/setup/` (in `flow/build_doc_/`), and keep `review/setup/status.md` current: what was done, what was found, what was decided and by whom, what it cost.

## Rules

* **The code is not yours to change here.** The commands are `mahdept …` and `docflow …`; the shared files (`makefile`, `flow/build_doc_/src/flow.yml`, the prompts) come from the template. A problem that needs a code or `flow.yml` change goes to `review/setup/problems.md`: what is wrong, the GRs it shows in (name, page, the line's text), how many GRs it touches, the change you propose. The person decides; a fix is made in the template and reaches this repo by `make upgrade` (code) or `copier update` (shared files).
* **The department's own values are settings, never code:** they live in the department's entry in the template's `depts.yml` (`~/orgpedia/mahnew/template.mahdept/depts.yml`), which copier renders into `department.yml` (`null`: not decided yet, and `make flow` refuses to start; `[]`: decided, none). You propose, the person decides, then you write their decision in `depts.yml`, commit the template, and run `make update_from_copier` here; never edit `department.yml`. `flow.yml` is the same in every department and takes the values from its `conf/values.yml`, which `mahdept values` writes from `department.yml` before every docflow command (the commands run in a task read the settings there too); never edit either by hand. Nothing is set for one GR. A difficult GR goes in `flow.yml`'s `exclude` with a reason, only with the person's agreement.
* **Money:** Cloud Vision (scanned pages) and Gemini (translation) cost money. Before any run that may call them, give the person the count and the cost and wait for a yes. Gemini goes by batch only (`DOCFLOW_DEFER`, then `docflow batch`). `DOCFLOW_CACHE_ONLY=gcv,gemini` makes a run that cannot pay: a call not already answered fails instead.
* **Don't look at page images.** Find things with code and counts; when the person must look, make them a sheet (a TSV or a page of samples) to mark.
* **Reuse first.** Another department's translation of a name or sentence is taken, not paid for again (`make pull_common` fetches their sheets).
* **Never push** (`make push_hf`) without the person's yes.

## 1. The GRs

```
make install
make list_all        # import/pdfs.txt from the department's files list on the dataset
make pull_hf         # the PDFs it lists, the GovDoc files and paid answers it has, from the dataset (PDFS_FROM=<folder>: PDFs a folder here has, linked)
make pull_common     # the department's lists, if any; the other departments' sheets
make import          # PDFs ready, the flow's links, its data (empty lists to begin with)
```

Record in `status.md`: GRs listed, PDFs found, missing (`import/src/missing.txt`), over the page limit (the status records in `flow/build_doc_/output/` whose `status` is `skipped`, after `make flow`), by year group (before 2010, 2010–2019, from 2020).

## 2. The department's values, before the flow

`department.yml` comes with what `depts.yml` has: the masthead names the portal gives for the department, and `set_aside.rules` as `null` until decided; check the names against the GRs' mastheads (older names, newest first); `make flow` will not start until both are decided. From what is there without the flow (the crawler's records in `LFS/mahGRs/infos/<code>/`: the portal's titles, its department name; the PDFs' text layers where they have one):

* **Masthead names:** the department line under "महाराष्ट्र शासन" at the top of its GRs, every name it has had (old and new), in Marathi, newest first. Propose what you can find with counts; the person often knows the old names. If they cannot be settled yet, the person may decide `[]` for the first run: the patterns that need a name then match nothing, and the names set later (step 4) re-run only the steps that use them.
* **GRs to set aside:** a kind of document of its own (Finance's: lottery results), by a word in the subject or the portal's title. Count the titles each candidate word matches. `[]` if there is none.
* **Page limit:** 20, as for every department, unless the person decides otherwise (it is already set: `make import` needed it).

Put them in `review/setup/values.md` with counts and examples. **Stop for the person's decision**, write it into the department's entry in `depts.yml` (commit the template, `make update_from_copier`), and check with `make check` (it says what is still undecided).

## 3. What reading it will cost

Run the flow so it cannot pay, to see which files need Cloud Vision:

```
DOCFLOW_CACHE_ONLY=gcv,gemini make flow
```

The files whose `text` step failed with `CacheOnly` need Cloud Vision (`flow/build_doc_/failed.txt`, `flow/build_doc_/logs/info.log`). Count their pages; at about $1.50 a 1,000 pages, give the person the cost. **Stop for a yes**, then run `make flow` (Gemini is never called by it: build_glossary_ and translate_ stop where a batch would be sent, with its count and cost).

## 4. The values again, from the flow's output

`make flow` has run `mahdept report repeats` in build_doc_: the lines that recur (the masthead's names among them, `logs/repeats.txt`) and the GRs the set-aside rules find, in `output/set_aside.txt` (a GR the person sets aside by hand goes in `conf/set_aside.txt`, with a reason). Count each masthead candidate's GRs by year; check the set-aside rules catch their kind and nothing else. If the names or rules should change, add it to `values.md` and **stop for the person's decision**; write it into the department's entry in `depts.yml` (commit the template, `make update_from_copier`), then `make flow` (`make -C flow/build_doc_ explain` first: only the steps a value touches run again).

## 5. The scorecard: how the results look

```
make check                  # the samples; every department.yml setting decided and in the flow
make review                 # the scorecard in Studio, for the person (it runs nothing)
```

The other departments' scorecards come with `make pull_common` and `make import` (each department's `make push_hf` uploads its own); `mahdept report scorecard --against <file>` compares with another. `make flow` writes it (`flow/build_doc_/review/setup/scorecard.txt`, about 30 lines; read only that, not the GRs; `make review` opens the page in Studio for the person). It gives each measure, as a count and its share, for the department and by year group beside Finance's, and flags (`!`) where this department is worse by 5 points or more: text (scans, OCR, characters not converted), fields and sections missing, sections found without their heading, tables, and two truths for every GR: the issue date read against the portal's date, the GR code read against the portal's code.

For each flag, find the cause with code and counts, not by reading pages: `review/setup/scorecard/<measure>.tsv` lists the GRs behind it with their text; the issues' details (`logs/info.issues.tsv`) have the lines (for a section found without its heading: how those lines begin, counted). A cause that touches many GRs (20 or more, or likely in other departments: a heading this department words differently, a list taken for an annexure) goes to `problems.md` with the lines' form, the GRs it touches and a proposed pattern. The person decides; fixes come through the template, measured on this department and Finance before they are committed. A field missing in a handful of GRs of one kind (letters, Gazette pages, old scans) is not a pattern: it goes to the person's queue (step 6). The scorecard counts what the GRs' text gave; the export fills the issue date and GR code from the portal where the text has none (`"from": "listing"`). `mahdept report sections|values|tables|lists` say more about one part when needed.

## 6. Samples

The scorecard also wrote `review/setup/samples.tsv`: 20 GRs across years and kinds (text layer, legacy font, scan, with a table), each with what was read beside the portal's date and code, and its PDF. Give it to the person to mark (`ok`, `note`).

The GRs with an order kind or number missing are set by the person in the reviewer's queue: write their document ids to `review/setup/missing_fields.txt` (from `scorecard/no_order_kind.tsv` and `no_order_number.tsv`, each GR's id from its export) and tell the person `make studio DOCS=review/setup/missing_fields.txt`, then "Missing fields: N to do" (click the words in order, Enter; `x` with a note if not printed). Their edits land in `flow/build_doc_/conf/` and the next `make flow` brings them in (build_doc_ spec §X7). For each GR they marked right, draft `flow/build_doc_/src/expected/<name>.yml` from its export (order number, date, GR code, the sections found). **Only what the person confirmed** goes in `expected/`; `make check` runs them from then on.

## 7. The lists

The lists are a task of their own, `flow/build_glossary_/` (its `spec.md`): it links build_doc_'s GovDoc files and other departments' sheets into its `input/`, and its `output/` is the department's lists. `make flow` has already run it up to the paid step: the candidates (the officers who sign, the table cells, the copy lists), the sheets with other departments' translations taken, `review/glossary/top.tsv` (the names not yet translated first, then the most used), and the count of what is left to translate, with its cost (in `make flow`'s output; `make -C flow/build_glossary_ count` again).

The person reads the candidate names first: `make review TASK=build_glossary_` opens them in Studio, each with its GRs. A name that is not one (a post, an office, a stray line of a signature) gets `x` in `top.tsv`'s `ok`, a wrong English the right one in `correct en`; the next `make -C flow/build_glossary_` takes the marks in (a name marked `x` is never sent). The candidates' own files are made again every run: never mark them. **Stop for a yes** on the cost, then:

```
make -C flow/build_glossary_ batch     # paid: the names and sentences left, then the version <today>
make -C flow/build_glossary_ export    # the new list files to export/build_glossary_/, linked
# then, in the department's entry in depts.yml: data: {profiles: mh_gr-1, registry: "<today>", memory: "<today>"},
# commit the template, make update_from_copier
make import && make flow               # build_doc_ and translate_ link the versions they pin
```

Report: names and sentences, how many reused (and from which departments), how many translated here, how many the person left out, conflicts (`conflicts.tsv`). The sheets themselves are never edited.

## 8. A pilot translation

Choose 50 GRs across years, with some scans; their file ids go in `flow/translate_/src/pilot.txt`. Then:

```
make flow                        # build_doc_, build_glossary_, translate_: what the call cache lacks waits for a batch, not sent
make -C flow/translate_ count    # the requests and their input tokens (free)
```

**Stop for a yes** on the cost, then `make -C flow/translate_ batch` (paid), `make flow` again, and `make review TASK=translate_` for the person's read-through (the pilot's page, `flow/translate_/review/translate/pilot.html`).

## 9. The status note and the push

`make export`; finish `status.md`: counts, the department's values and who decided them, problems open, money spent (Cloud Vision, Gemini). **Ask before `make push_hf`**; it uploads the GovDoc files, the paid answers and the lists to the dataset. Then commit: the links, the status records, the edits, the review files (`make check` refuses while a GovDoc file is not exported).
