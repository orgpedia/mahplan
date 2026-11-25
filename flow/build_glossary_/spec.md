# build_glossary_: the Department's Glossary and Translation Memory

(Named `lists_` until November 19: the template's decision 40. The folder is renamed with the release.)

**Version:** 0.3 (November 21: no PDFs in `input/`, since the task does not process them; `make review` passes `PDFS_DIR` to Studio, `docflow.md` §N27 rule 10). 0.2 (November 19, built the same day: renamed build_glossary_; it makes its own candidates (the officers, the table cells, the copy lists) from build_doc_'s GovDoc files; its default target runs everything up to the batch and, once the answers are in, writes a new version; `make review` opens Studio at a page of the candidate names; §L1–§L4; decided, not built). 0.1 (November 19, 2026: the glossary and memory builders as a task of their own, orgpedia/doc `docflow.md` §N19 item 5; the template's decision 39) · @Mukund

**Builds on:** orgpedia/doc `specs/mahgrs.md` §W15 (the lists: sheets, versions, corrections, other departments' translations), `docflow.md` §N9 (a task reads only its own folder), §N19 and §N20 (a task's name and its two targets); the template's spec §G4a. The commands: `mahdept glossary …`, `mahdept memory …` (this repo's `packages/mahdept`), run in this folder.

## L1. What it does

It makes the department's glossary and translation memory from the GRs build_doc_ read:

1. **The candidates,** from build_doc_'s GovDoc files in its `input/`: the officers who sign and the posts they sign as (from the signature blocks), the table cells that recur, the names in the copy lists, and the sentences found in 10 GRs or more; the GRs set aside (build_doc_'s `output/set_aside.txt`) left out. Until November 19 the first three were made by build_doc_'s `mahdept report repeats` and `report tables` in its `review/`, and read from there.
2. **The reuse:** a name or sentence another department has translated is taken from its sheet, not asked again.
3. **The English of the rest,** by Gemini, by batch only, once its cost is agreed.
4. **The versions:** the glossary of names (offices, posts, departments, places) compiled into the registry the flows pin (`registry/<version>.json`), and the memory (`memory/mr_en.tsv`, `memory/mr_en/<version>.json`).

## L2. The folder

| | |
|---|---|
| `input/` | links, a file each, made by `make input`: `govdoc/<name>.govdoc.json.zst` (each of build_doc_'s GovDoc files), `set_aside.txt` (build_doc_'s `output/set_aside.txt`), `sheets/<dept>/<list>/mr_en.tsv` and its corrections (each other department's, from the repo's `import/sheets/`) |
| `conf/values.yml` | the department's settings, written from `department.yml` (`mahdept values`) |
| `output/` | the lists: `glossary/`, `registry/`, `memory/`; a new file is a file of its own until `make export` moves it to `../../export/build_glossary_/` and leaves a link; `make import` takes them out of the dataset into `export/build_glossary_/` and links any missing here |
| `responses` | a link to `../../export/build_glossary_/responses/`: Gemini's answers for the names (`glossary_english/`) and the sentences (`memory_english/`), packed by month and pushed by `make push_hf` |
| `review/` | what a person reads: `glossary/officers.tsv`, `cells.tsv`, the copy lists (the candidates, rebuilt by every `make`), `glossary/top.tsv` (the most used names, to mark), the conflicts, `studio.yml` (Studio on the GovDoc files in `input/`), the names page `make review` opens; `review/tmp/` (the batch's waiting requests) not committed |

build_doc_ and translate_ link the versions they pin, a file each, from this task's `output/` (`input/data/registry/<version>.json`, `input/data/memory/<version>.json`).

## L3. Its targets (November 19, template decision 40; decided, not built)

* **`make`** (the default, and what the top `make flow` runs after build_doc_): `make input`; the candidates and the names page (`mahdept glossary candidates`, §L1 step 1); the glossary and memory sheets brought up to date, other departments' translations taken (`glossary build`, `memory build`, `memory short` at the pinned memory); the marks of `review/glossary/top.tsv` taken in and the sheet written again (`glossary review --take`, then `glossary review`: the names not yet translated first, then the most used); then the count of the names and sentences left to translate and their cost (`--count`, free). It never calls Gemini.
* **`make batch`** (paid): the names and the sentences left, one Vertex AI batch each (`--batch`), then the new version, named by the day (`glossary compile --version <today>`, `memory english --batch --version <today>`).
* **Pinning** is the person's: the flows read the version the department's entry in the template's `depts.yml` pins (`data:`); a new version changes nothing until it is pinned (`mahgrs.md` §W3 item 7).
* **`make review`:** Studio on the GovDoc files in `input/` (read only: `fixes: []`; the page images from the PDFs in `PDFS_DIR`, the repo's `import/pdfs/` unless given, `studio serve --pdfs`: not linked into `input/`, since this task does not process them, `docflow.md` §N27 rule 10), opened in the browser at the names page: each candidate name (officers, posts, cells, copy-list names) with its GR count, other spellings and posts, and a link to its GRs in Studio. A name that is not a name, or whose English is wrong, is marked in `review/glossary/top.tsv` (`x` to leave it out, or the right English), never in the candidates' sheets, which every `make` rebuilds. Nothing is run.

## L4. Open

* `mahdept glossary names --add` (run in translate_) adds draft rows to this task's glossary sheet: to move here.
* Marking a name in Studio itself, not in `top.tsv`: later.
