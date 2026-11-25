# Maharashtra Planning Department GRs

The Planning Department's GRs (the crawler's code `mahplan`), read with GovDoc and docflow (orgpedia/doc) and reviewed
in GovDoc Studio. The flow reads the GRs of at most `max_pages` pages (department.yml).

Made from the copier template orgpedia/template.mahdept and kept up to date from it by `make update_from_copier`: its
shared files, its settings (the template's `depts.yml`) and the release of its code (the `mahdept` and `docflow`
commands, imported, not copied, pinned by tag; `make dev` puts the local checkouts in while building them). To set the department
up, ask Claude in this repo to set up the department: it follows `.claude/skills/new-department/SKILL.md`.
What this repo does is in the template's `spec.md`; what each task does is in its own spec, `flow/<task>/spec.md`.
Only `department.yml` (the department's settings) differs between departments; `flow/build_doc_/src/flow.yml` is the same
in every one, taking the department's values from it.

**No hand-written fixes.** The flow has department-wide settings only. Checkers find what went wrong, a person
fixes it in the reviewer, and the fixes are recorded as edits (`flow/build_doc_/conf/<file>.edits.yml`) and replayed on
every run. Difficult documents go in `exclude` in `flow/build_doc_/src/flow.yml`, with a reason.

## The layout

```
department.yml                        the department's settings, rendered from the template's depts.yml (never edited here);
                                      null until decided (make flow waits for them)
.copier-answers.yml                   copier's answers: the code (the rest is the department's entry in depts.yml)
.env                                  credentials and settings, never committed (cp env.example .env)
import/                               what comes in, made ready from LFS/ by make import (not committed but pdfs.txt in a trial)
  pdfs.txt                            the GRs every step works from: <dept>/<YYYY-MM>/<name>, one a line
  pdfs/<YYYY-MM>/<name>.pdf           every listed PDF, out of its month's zip, unique by content
  infos/<kind>/<YYYY>.jsonl           the crawler's records, copied out of LFS/mahGRs/infos/<dept>/ (make import)
  src/                                sources.json, duplicates.txt, missing.txt (written by make import)
export/                               what goes out: each task's GovDoc files and paid answers (not committed; make push_hf)
flow/
  build_doc_/                         the core task: PDF to GovDoc file (spec.md); it reads and writes only its own folder
    input/                            links (make input): pdfs/<YYYY-MM>/<name>.pdf, sources.json, scorecards/ (committed)
    src/                              flow.yml (the same in every department), prompts/, expected/ (the samples); data/
    conf/                             <name>.edits.yml: a person's fixes (the reviewer's), values.yml (from department.yml),
                                      set_aside.txt (GRs a person sets aside, with a reason)
    output/<name>.status.json         each GR's status record: what was done, its issues, where its GovDoc file is (committed)
    output/<name>.govdoc.json.zst     the GovDoc file, a link into ../../export/build_doc_/ after make export (the link committed)
    output/set_aside.txt              the GRs set aside: the rules' (department.yml) and conf/set_aside.txt's (committed)
    responses                         a link to ../../export/build_doc_/responses/: Cloud Vision's answers (committed)
    cache/                            unipdf's answers, made again at no cost (not committed)
    review/                           studio.yml, issue_counts.html, the scorecard; review/tmp/ (not committed)
    README.md                         the task's issues (make export)
    logs/                             not committed
  build_glossary_/                    the department's glossary and translation memory, from build_doc_'s files (its
                                      input/govdoc/ links each one) and other departments' sheets; output/ the lists
  translate_/                         the English, a layer a GR over build_doc_'s files (its input/govdoc/ links each one)
LFS/mahGRs/                           the HF dataset Orgpedia/mahGRs at its own paths (not committed): pdfs/, infos/,
                                      govdocs/mahplan/, responses/mahplan/, flow/mahplan/common/ (the lists)
```

## Running it

```sh
cp env.example .env                             # then fill it in: make install refuses without it
make install                                    # uv sync
make list_all pull_hf pull_common import         # every GR on the dataset (make list_recent for the current and the last month)
                                                # then decide the nulls in the template's depts.yml, commit it,
                                                # make update_from_copier
make flow                                       # every task, each making all the next one reads: build_doc_,
                                                # build_glossary_, translate_; refuses while department.yml has a
                                                # null; Gemini is never called (a task says what waits, and its cost)
make review                                     # optional: build_doc_'s scorecard in Studio, in the browser
                                                # (TASK=build_glossary_: the candidate names; TASK=translate_: the pilot)
make -C flow/build_glossary_ batch              # paid, when agreed: the names and sentences left, then a new version
make export push_hf                             # the GovDoc files and paid answers to the dataset; then
git add -A && git commit                        # links, status records, edits: nothing large
make check                                      # the samples against src/expected/; department.yml against flow.yml
```

`make` alone lists the targets. The targets say briefly what they did; `QUIET=1` (the scheduled jobs) leaves only
the errors: `make QUIET=1 list_recent pull_hf import flow export push_hf`.
