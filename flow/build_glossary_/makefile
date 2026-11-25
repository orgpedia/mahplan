# build_glossary_ (was lists_; the template's decision 40; its spec.md): the department's glossary of names (offices,
# posts, places), its registry (the glossary compiled, a dated version) and its translation memory (fixed sentences),
# each with its English. It reads only its own folder: make input links into input/ each of build_doc_'s GovDoc files
# (with its status record), build_doc_'s GRs set aside (its output/set_aside.txt), and each other
# department's sheets (from the repo's import/sheets/, so a name or sentence another department translated is taken,
# not paid for again). Its output/ is the lists; make export moves the new files to ../../export/build_glossary_/ and
# links them; make push_hf (at the repo's root) copies them into the dataset's flow/<dept>/common/. Gemini's answers
# are kept in responses/, a link to ../../export/build_glossary_/responses/, pushed like every paid answer.
#
#   make           everything up to the paid step: the candidates (officers, table cells, copy lists, from build_doc_'s
#                  GovDoc files), the sheets with other departments' translations taken, a person's marks taken in
#                  (review/glossary/top.tsv), the names to read written again, then the count and cost of what is
#                  left to translate. Gemini is never called.
#   make batch     (paid) what is left, by batch; then a new version of the registry and the memory, named by the day.
#                  The flows read the version depts.yml pins (data:): pin it there on purpose.
#   make review    Studio, opened at the candidate names (review/glossary/names.html); the marks go in top.tsv;
#                  the page images from PDFS_DIR (the repo's import/pdfs/ unless given: make review PDFS_DIR=<folder>)

ifneq (,$(wildcard ../../.env))
include ../../.env
export
endif

run := uv run --no-sync
PORT ?= 8811
# where make review finds the PDFs for Studio's page images, by name at any depth: not linked into input/, since this
# task does not process them (orgpedia/doc docflow.md §N27 rule 10); gone after make clean_pdfs, until make import
PDFS_DIR ?= ../../import/pdfs
today := $(shell date +%Y-%m-%d)

.PHONY: all values input candidates sheets marks count batch review check export

all: input candidates sheets marks count

values:
	@$(run) mahdept values

input: values
	@$(run) mahdept inputs --task build_glossary_

# the officers who sign, the table cells, the copy lists (review/glossary/), and the names page for make review
candidates: values
	$(run) mahdept glossary candidates

# the department's sheets: the names and the fixed sentences found, beside other departments' translations
sheets: values
	$(run) mahdept glossary build
	$(run) mahdept memory build
	$(run) mahdept memory short

# a person's marks in review/glossary/top.tsv taken in (x: leave the name out, never translated; or the right
# English), then the most used names not yet read written there again
marks: values
	@test ! -s review/glossary/top.tsv || $(run) mahdept glossary review --take review/glossary/top.tsv
	$(run) mahdept glossary review

# what is left to translate and what it would cost (free); make batch sends it
count: values
	$(run) mahdept glossary english --count
	$(run) mahdept memory english --count
	@echo "build_glossary_: make batch sends what is left (paid), then writes the version $(today)"

batch: values
	$(run) mahdept glossary english --batch
	$(run) mahdept glossary compile --version $(today)
	$(run) mahdept memory english --batch --version $(today)
	@echo "build_glossary_: version $(today) written; pin it in depts.yml (data: registry, memory), then make update_from_copier"

# what a person reviews, in the browser: Studio on build_doc_'s GovDoc files (input/govdoc/), opened at the candidate
# names, each with a link to its GRs, the page images from PDFS_DIR. Nothing is run (make first); Ctrl+C stops it
review:
	@test -f review/glossary/names.html || { echo "review: no names page yet (make, or make candidates)"; exit 1; }
	$(run) studio serve --port $(PORT) --dir input/govdoc --pdfs $(PDFS_DIR) --page review/glossary/names.html

check:
	@echo "build_glossary_: no samples"

# the new list files moved to ../../export/build_glossary_/ and linked (make push_hf copies them to the dataset)
export: values
	$(run) mahdept lists export
