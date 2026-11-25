# The flow (src/flow.yml): input/govdoc/*.govdoc.json.zst (links to build_doc_'s output/) -> output/*.en.json.zst, one
# layer a GR: the names found, the English, the checks. build_doc_'s files are read, never copied or written.
# The task keeps its own files, with no working store (orgpedia/doc docflow.md §N9, §N10): make input links each of
# build_doc_'s GovDoc files into input/govdoc/; a layer is a file of its own in output/ until make export moves it to
# ../../export/translate_/ and leaves a link; each GR's status record, output/<name>.status.json, is in git. Gemini's
# answers are kept in responses/ (a link to ../../export/translate_/responses/, pushed to the dataset).
# Messages go to logs/info*.log, run logs to logs/run-*.jsonl.
#
# make flow never calls the model: a sentence whose answer is not in the call cache is written to
# review/tmp/defer.jsonl (written afresh each run: only what this run lacks), and its GR waits. make count says what a batch of them would send (free); make batch sends
# it (paid: agree the cost first) and takes the answers into the cache; make flow again then finishes those GRs.

ifneq (,$(wildcard ../../.env))
include ../../.env
export
endif

run := uv run --no-sync
docflow := $(run) docflow
flow := src/flow.yml
defer := $(CURDIR)/review/tmp/defer.jsonl
export DOCFLOW_DEFER ?= $(defer)

.PHONY: all values input flow count batch validate issues explain check export output report pilot review

# everything (the template's §G4a): the flow (what Gemini would be asked waits for make batch), the checks, the
# pilot's page (review/translate/pilot.html) when src/pilot.txt names GRs
all: flow validate issues pilot

values:
	@$(run) mahdept values

# each of build_doc_'s GovDoc files linked into input/govdoc/, a link each, never removed
input:
	@$(run) mahdept inputs --task translate_

# docflow run exits 1 when some files failed or wait for a batch (failed.txt): the rest is kept
flow: values input logs
	@mkdir -p review/tmp
	@rm -f $(defer)
	$(docflow) run $(flow) $(if $(QUIET),--progress off) > logs/info.log; rc=$$?; test $$rc -le 1 || exit $$rc; \
	n=$$(test -f $(defer) && wc -l < $(defer) | tr -d ' ' || echo 0); \
	test $$n -eq 0 || echo "flow: $$n requests wait for a batch (make count: what it would send; make batch: send it, paid)"

# what a batch would send: the requests and their input tokens (free)
count:
	@test -s $(defer) || { echo "count: nothing waits for a batch"; exit 0; }; $(docflow) batch $(flow) $(defer) --count

# send what waits as one Vertex AI batch, wait for it, take its answers into the call cache (paid; DOCFLOW_BATCH_BUCKET)
batch:
	@test -s $(defer) || { echo "batch: nothing waits for a batch"; exit 1; }
	$(docflow) batch $(flow) $(defer)

validate: values
	$(docflow) validate $(flow) > logs/info.validate.log

issues: values
	$(docflow) issues $(flow) > logs/info.issues.tsv

explain: values
	$(docflow) explain $(flow) > logs/info.explain.log
	@awk 'NF && !/^f_/ {print $$1, $$2}' logs/info.explain.log | sort | uniq -c | grep -vE ' (skip|n/a)$$' || echo "nothing to run again"

# the pilot's translations for a person to read: review/translate/pilot.txt and pilot.html (Marathi, English, how
# each was made)
report:
	$(run) mahdept report translate

pilot:
	@test -z "$$(tr -d '[:space:]' < src/pilot.txt)" || $(run) mahdept report translate

# the pilot's page in the browser (make first); nothing is run
review:
	@test -f review/translate/pilot.html || { echo "review: no pilot page (src/pilot.txt names no GR, or make first)"; exit 1; }
	$(run) python -m webbrowser -t "file://$(CURDIR)/review/translate/pilot.html"

check: values
	@echo "translate_: no samples yet"

# the new layers moved to ../../export/translate_/ and linked; each GR's status record and the issues written
# (orgpedia/doc docflow.md §N12, §N14)
export: values
	$(docflow) export $(flow)
output: export  # the old name

logs:
	mkdir -p logs
