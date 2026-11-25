# build_doc_ (was text_; the template's decision 40): a GR's PDF to its GovDoc file. `make` runs everything the tasks
# after it read (the flow, the GRs set aside, the tables' columns, the issues, the scorecard); `make review` opens
# Studio at the scorecard. The flow (src/flow.yml): input/pdfs/<YYYY-MM>/*.pdf -> output/*.pdf.govdoc.json.zst (the reports make each GR's
# export from it: mahdept.exports, review/tmp/exports/).
# The task keeps its own files, with no working store (orgpedia/doc docflow.md §N9): it reads only its folder, its
# input/ linked by make input (the PDFs and the portal's records in the repo's import/); a new GovDoc file is a file
# of its own in output/ until make export moves it to ../../export/build_doc_/ and leaves a link, which later runs read and
# write through; each GR's status record, output/<name>.status.json, is in git. Cloud Vision's answers are kept in
# responses/ (a link to ../../export/build_doc_/responses/, pushed to the dataset), unipdf's in cache/ (made again).
# Messages go to logs/info*.log, run logs to logs/run-*.jsonl. Every docflow command first writes conf/values.yml from
# ../../department.yml (mahdept values), and stops, saying what, while the department has a setting not decided (null).

# the repo's .env (credentials and settings), when there is one
ifneq (,$(wildcard ../../.env))
include ../../.env
export
endif

run := uv run --no-sync
docflow := $(run) docflow
flow := src/flow.yml
# where make studio serves the reviewer; the scorecard's links open it there (other Studios often hold 8800-8801)
PORT ?= 8810

.PHONY: all values input listed import flow validate issues scorecard explain expect check export output repeats tables studio review

# everything, the files the tasks after it read included (the template's §G4a): the run, then the reports
all: import flow validate repeats tables issues scorecard

# the department's values the flow puts in (flow.yml: values), from department.yml
values:
	@$(run) mahdept values

# the task's input/, linked from the repo's import/ (make import fills it): every listed PDF, a link each, never removed
input: listed
	@$(run) mahdept inputs --task build_doc_

# the repo's list of GRs, import/pdfs.txt: gone after make clean_pdfs (the repo's), and then nothing here that reads the
# PDFs runs (its input/pdfs/ links lead nowhere) until make list_all pull_hf import, in the repo's folder
listed:
	@test -s ../../import/pdfs.txt || { echo "build_doc_: no import/pdfs.txt (make clean_pdfs took the PDFs away):" \
	  "make list_all pull_hf import first, in the repo's folder; translate_ runs without them (make -C flow/translate_)"; exit 1; }

import: listed values input logs
	$(docflow) import $(flow) > logs/info.import.log

# In a terminal, docflow run says on the screen how far it is and about how long is left (the summary goes to
# logs/info.log); QUIET=1 silences it. docflow run exits 1 when some files failed (failed.txt): the rest is kept, linked and checked, and the next
# make flow runs only what failed; any other error stops here.
#
# The pages read whole by OCR go to IndicOCR by batch (orgpedia/doc specs/mahgrs.md §W16): the text step runs with
# its IndicOCR requests deferred (DOCFLOW_DEFER: logs/deferred.jsonl, the images beside it), docflow batch sends them
# to the gateway (paid: the count and cost in logs/info.batch.log; it stops make when the gateway is out of money),
# and the step runs again; a page with a block cut off is asked again, so twice. Then mahdept ocr pick names the
# doubtful pages Cloud Vision reads, within cloud_vision_budget (department.yml), in conf/overrides/text/, and the
# whole flow runs. Files still waiting for IndicOCR (a page the gateway failed) fail; make flow again sends them.
DEFER := logs/deferred.jsonl
text_run = DOCFLOW_DEFER=$(DEFER) $(docflow) run $(flow) --steps import..text --progress off >> logs/info.text.log; \
	rc=$$?; test $$rc -le 1 || exit $$rc
# nothing deferred by the first text pass (a run with ocr: none, or every answer in the call cache): no batch and no
# second or third pass, each of which would only find every file's stamp the same (about 0.2 s a GR)
deferred := test ! -s $(DEFER) ||
flow: listed values logs
	@rm -rf logs/deferred.jsonl logs/deferred.jsonl.files; : > logs/info.text.log; : > logs/info.batch.log
	$(text_run)
	$(deferred) $(docflow) batch $(flow) $(DEFER) >> logs/info.batch.log
	$(deferred) $(text_run)
	$(deferred) $(docflow) batch $(flow) $(DEFER) >> logs/info.batch.log
	$(deferred) $(text_run)
	$(run) mahdept ocr pick > logs/info.pick.log && cat logs/info.pick.log
	DOCFLOW_DEFER=$(DEFER) $(docflow) run $(flow) $(if $(QUIET),--progress off) > logs/info.log; rc=$$?; test $$rc -le 1 || exit $$rc; \
	test $$rc -eq 0 || echo "flow: $$(wc -l < failed.txt | tr -d ' ') files failed (failed.txt; why: grep ERROR logs/info.log); make flow again runs only them"

validate: values
	$(docflow) validate $(flow) > logs/info.validate.log

# every issue, one row each, with its page and details
issues: values
	$(docflow) issues $(flow) > logs/info.issues.tsv

# how the run went, for a person to read before committing: review/setup/scorecard.html (and .txt, .json), beside
# every other department's scorecard (the repos next to this one) and this one's last
scorecard: issues
	$(run) mahdept report scorecard --studio http://localhost:$(PORT)/

# what a run would do, step by step, counted (logs/info.explain.log has every file's)
explain: values
	$(docflow) explain $(flow) > logs/info.explain.log
	@awk 'NF && !/^f_/ {print $$1, $$2}' logs/info.explain.log | sort | uniq -c | grep -vE ' (skip|n/a)$$' || echo "nothing to run again"

# the GRs set aside, each with its reason (output/set_aside.txt: the rules in ../../department.yml, and the rows a
# person adds in conf/set_aside.txt), and how much of the text repeats (logs/repeats.txt). The glossary's candidates
# are build_glossary_'s (it makes them from this task's GovDoc files)
repeats:
	$(run) mahdept report repeats

# the tables' columns by kind (logs/tables.txt, review/tables/columns.tsv) (after make repeats: it reads output/set_aside.txt)
tables:
	$(run) mahdept report tables

# the samples (src/expected/<name>.yml) against the exports made from their GovDoc files (review/tmp/exports/)
expect: values
	$(run) mahdept expect

# the samples, and department.yml against flow.yml (the template's spec §G6)
check: values expect
	$(docflow) patterns $(flow)
	$(run) mahdept check

# the new GovDoc files moved to ../../export/build_doc_/ and linked; each GR's status record (output/<name>.status.json) and
# the issues (README.md, review/issue_counts.html) written (orgpedia/doc docflow.md §N12, §N14)
export: values
	$(docflow) export $(flow)
output: export  # the old name

logs:
	mkdir -p logs

# The reviewer (orgpedia/doc: specs/studio.md): every file in output/, or fewer with
# DOCS=<file of doc ids, one a line>, DOC=<doc id> or DIR=<folder of GovDoc files>. Edits go to conf/.
studio:
	$(run) studio serve --port $(PORT) $(if $(DOCS),--docs $(DOCS)) $(if $(DOC),--doc $(DOC)) $(if $(DIR),--dir $(DIR))

# what a person reviews, in the browser: Studio on every file in output/, opened at the scorecard, whose every cell and
# issue opens its GRs. Nothing is run (make first); Ctrl+C stops it
review:
	@test -f review/setup/scorecard.html || { echo "review: no scorecard yet (make, or make scorecard)"; exit 1; }
	$(run) studio serve --port $(PORT) --page review/setup/scorecard.html
