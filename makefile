.DEFAULT_GOAL := help

# Planning Department (mahplan), a department made from orgpedia/template.mahdept (its spec.md §G4).
# Everything works from import/pdfs.txt: the list targets write it (or a person does, in a trial), the rest read it.
#   daily:  make QUIET=1 list_recent pull_hf import flow export push_hf     (the scheduled job: errors only)
#   full:   make list_all pull_hf import flow export push_hf, then git add, git commit
#   trial:  make pull_hf import flow export              (import/pdfs.txt written by hand)
# The targets say briefly what they did (make flow: how far it is and about how long is left, when run in a terminal);
# QUIET=1 silences that, leaving the errors.

dept := mahplan
kind := department

# credentials and settings (GOOGLE_CLOUD_PROJECT, DOCFLOW_BATCH_BUCKET, HF_TOKEN…), never committed; see env.example
ifneq (,$(wildcard .env))
include .env
export
endif

# --no-sync: keep the environment created by `make install`
run := uv run --no-sync

# The HuggingFace dataset the records and the PDFs come from, and the results go to, at the same paths as LFS/mahGRs/
# (orgpedia/doc specs/mahgrs.md §W6). hf is huggingface_hub's command; HF_TOKEN (.env) is read by it.
HF_DATASET ?= Orgpedia/mahGRs
# no adverts from hf for its own tools; pull says itself which PDFs were not on the dataset (hf's own line left out)
hf_get := env HF_HUB_DISABLE_UPDATE_CHECK=1 $(run) hf download $(HF_DATASET) --repo-type dataset --local-dir LFS/mahGRs --quiet
hf_put := $(run) hf upload $(HF_DATASET) --repo-type dataset
# the lines of import/pdfs.txt, comments and blank lines left out: <dept>/<YYYY-MM>/<name>
listed := sed -e 's/\#.*//' -e 's/[[:space:]]//g' -e '/^$$/d' import/pdfs.txt
# a status line, in a recipe's shell: echo, or nothing with QUIET=1
QUIET ?=
export QUIET
say := $(if $(QUIET),:,echo)

# in the order they run (the template's decision 40: named for what they do): build_glossary_ and translate_ read
# build_doc_'s output (their input/govdoc/), translate_ the lists build_glossary_ makes (input/data/, the pinned
# versions). make flow runs each task's default target, which makes everything the tasks after it read
tasks := build_doc_ build_glossary_ translate_
# make review TASK=<task>: which task's review make review opens
TASK ?= build_doc_

.PHONY: help install upgrade dev update_from_copier list_recent list_all list_text_all pull_common pull_hf import input flow review scorecard export output push_hf clean_images clean_pdfs check studio

help:
	$(info Please use 'make <target>', where <target> is one of)
	$(info )
	$(info   install       the environment (uv sync): the code at the commits uv.lock records)
	$(info   upgrade       the code uv.lock pins (by tag: docflow, mahdept), then what it would run again and the samples)
	$(info   dev           the local checkouts of the code over the pinned one, for building it (make install undoes it))
	$(info   update_from_copier  the template's files, depts.yml's settings, the code's release (copier update), then the values)
	$(info                 (commit first: copier needs a clean repo; one target with upgrade once both settle))
	$(info   list_recent   import/pdfs.txt: the department's GRs on HF of the current and the last month (its files list))
	$(info   list_all      import/pdfs.txt: every GR of the department on HF (its files list, pdfs/$(dept)/$(dept)_files.txt))
	$(info   list_text_all import/pdfs.txt: only the GRs whose PDF is all text (the crawler's pdfinfo: no scans, no image)
	$(info                 pages, no old fonts), for a run with no OCR; set ocr: none in department.yml for it)
	$(info   pull_common   the department's lists; the other departments' sheets (from HF))
	$(info   pull_hf       what import/pdfs.txt lists, from the HF dataset Orgpedia/mahGRs into LFS/mahGRs/: the PDFs')
	$(info                 months, the tasks' GovDoc files of those months, every paid answer of the department)
	$(info                 (PDFS_FROM=<folder>: the PDFs that folder has are linked, only the rest fetched))
	$(info   import        LFS/ into import/ (the listed PDFs, unique by content; the sources; the data) and export/)
	$(info                 (the tasks' earlier GovDoc files and paid answers); each task links its own input/ in make flow)
	$(info   flow          run every task, each making all the next one reads: $(tasks))
	$(info                 (not while department.yml has a setting not decided: null); Gemini is never called: a task)
	$(info                 says what waits and its cost, and make -C flow/<task> batch sends it (paid))
	$(info   review        open what to review in the browser: build_doc_'s scorecard in Studio (TASK=build_glossary_:)
	$(info                 the candidate names; TASK=translate_: the pilot's page); runs nothing)
	$(info   scorecard     build_doc_'s scorecard again (make flow makes it): flow/build_doc_/review/setup/scorecard.html)
	$(info   export        each task's new GovDoc files moved to export/<task>/ and linked; status records and issues)
	$(info   push_hf       export/ packed a month to a zip in LFS/ and uploaded, with the department's lists; then commit)
	$(info   clean_images  the page images sent to IndicOCR (flow/build_doc_/logs/, and its workspace), after push_hf and git commit)
	$(info   clean_pdfs    the PDFs and import/pdfs.txt (not while build_doc_ has failed GRs); build_doc_ then waits)
	$(info                 for make list_all pull_hf import; translate_ runs without them: make -C flow/translate_)
	$(info   check         the samples against what is expected of them; every department.yml setting decided)
	$(info   studio        Studio on build_doc_'s files, at its documents; edits go to flow/build_doc_/conf/)
	$(info )
	$(info Check the makefile to know exactly what each target is doing.)
	@echo # dummy command

# .env first: every target after this reads it (HF_TOKEN for the dataset, the Google project for Cloud Vision and Gemini)
install: pyproject.toml
	@test -f .env || { echo "install: no .env. Make it from env.example (cp env.example .env) and fill it in: HF_TOKEN, GOOGLE_CLOUD_PROJECT, DOCFLOW_BATCH_BUCKET"; exit 1; }
	uv sync

# The code is imported (template spec §G1a): docflow and GovDoc from orgpedia/doc, mahdept from template.mahdept,
# pinned by tag in pyproject.toml (from copier.yml) and by commit in uv.lock (committed). A new release reaches the repo
# by update_from_copier; upgrade then takes the code the lock pins, shows what would run again, checks the samples.
upgrade:
	uv sync
	$(run) make -C flow/build_doc_ explain
	$(MAKE) check

# For building the code: the local checkouts (../../doc, ../template.mahdept) installed over the pinned code, so a change
# there is live at once. Nothing is committed by it; make install puts the pinned code back. A run made this way is
# not repeatable from the lock: release (tag) the code before the run whose results are kept.
dev:
	uv pip install --no-deps -e ../../doc/packages/govdoc -e ../../doc/packages/docflow -e ../../doc/packages/studio \
	  -e ../template.mahdept/packages/mahdept

# The template's copied files and this department's settings (department.yml, from the template's depts.yml, its
# spec decision 36): copier's three-way merge keeps what is the repo's own and marks a conflict in the file. Then each
# task's conf/values.yml from department.yml. Kept apart from upgrade (the code) until the two settle into one target.
update_from_copier:
	@test -z "$$(git status --porcelain)" || { echo "$@: commit or stash first (copier update needs a clean repo)"; exit 1; }
	copier update --trust --defaults
	uv sync
	$(run) mahdept values

# The records and the PDFs always come from the dataset, into LFS/mahGRs/ at its own paths: infos/<dept>/, and the
# PDFs packed a month to an archive, pdfs/<dept>/<YYYY-MM>.zip (<name>.pdf inside), with pdfs/<dept>/<dept>_files.txt
# listing every PDF the archives hold (<YYYY-MM>/<name>.pdf). A list target fetches the department's files list (again
# when the dataset's copy changed) and lists only what it names: getting the PDFs is the crawler's job, not this repo's
# (a trial's list is written by hand). pull_hf fetches the records and the files list of every department the list names,
# then the archive of each month that holds a listed GR whose PDF is not here loose (hf fetches an archive again only
# when the dataset's copy changed: the current month's, as GRs are added). A GR of a hand-written list the files list
# does not name is not on the dataset: make import lists it in import/src/missing.txt. make import
# takes the PDFs out of the archives (template spec §G4). It copies the records out of LFS/mahGRs/infos/<dept>/ into
# import/infos/<kind>/<YYYY>.jsonl, a file each (import/ holds files, never a link to a folder: docflow.md §N25).
# make pull_hf PDFS_FROM=<folder>: the listed PDFs that folder already has (at the dataset's paths, or by name) are
# linked into LFS/mahGRs/pdfs/<dept>/<YYYY-MM>/, loose; only the months still missing a PDF are fetched. The folder
# must stay: links.
list_recent list_all:
	@test "$(kind)" != trial || { echo "$@: a trial's import/pdfs.txt is written by hand"; exit 1; }
	@$(say) "$@: the department's files list (pdfs/$(dept)/$(dept)_files.txt) from $(HF_DATASET)"
	@$(hf_get) pdfs/$(dept)/$(dept)_files.txt > /dev/null
	@$(run) mahdept list --$(subst list_,,$@) $(if $(QUIET),> /dev/null)

# only the GRs whose PDF is all text, by the crawler's pdfinfo (mahgrs.md §W17): the scans, the PDFs with image pages or
# old fonts and those with no pdfinfo wait for a later run. The files list and the pdfinfos fetched from the dataset
list_text_all:
	@test "$(kind)" != trial || { echo "$@: a trial's import/pdfs.txt is written by hand"; exit 1; }
	@$(say) "$@: the department's files list and pdfinfos from $(HF_DATASET)"
	@$(hf_get) pdfs/$(dept)/$(dept)_files.txt > /dev/null
	@$(hf_get) --include "infos/$(dept)/pdfinfos/*" > /dev/null
	@$(run) mahdept list --text-all $(if $(QUIET),> /dev/null)

pull_hf:
	@test -f import/pdfs.txt || { echo "pull_hf: no import/pdfs.txt (make list_all or list_recent; a trial's by hand)"; exit 1; }
	@mkdir -p import/src
	@for d in $$($(listed) | cut -d/ -f1 | sort -u); do \
	  $(hf_get) infos/$$d/ > /dev/null || exit 1; \
	  $(hf_get) pdfs/$$d/$${d}_files.txt > /dev/null 2>&1 || echo "pull_hf: no pdfs/$$d/$${d}_files.txt on $(HF_DATASET)" >&2; \
	done
	@test -z "$(PDFS_FROM)" || $(run) mahdept pdfs-from "$(PDFS_FROM)"
	@n=$$($(listed) | wc -l); \
	$(listed) | while IFS=/ read d m g; do test -e LFS/mahGRs/pdfs/$$d/$$m/$$g.pdf || echo $$d/$$m/$$g; done \
	  | sort > import/src/not_loose.txt; \
	for d in $$(cut -d/ -f1 import/src/not_loose.txt | sort -u); do \
	  f=LFS/mahGRs/pdfs/$$d/$${d}_files.txt; test ! -f $$f || sed -e "s|^|$$d/|" -e 's|\.pdf$$||' $$f; \
	done | sort > import/src/on_dataset.txt; \
	comm -12 import/src/not_loose.txt import/src/on_dataset.txt > import/src/in_archives.txt; \
	cut -d/ -f1,2 import/src/in_archives.txt | sort -u | sed 's|.*|pdfs/&.zip|' > import/src/fetch.txt; \
	h=$$((n - $$(wc -l < import/src/not_loose.txt))); a=$$(($$(wc -l < import/src/in_archives.txt))); \
	k=$$(($$(wc -l < import/src/fetch.txt))); n=$$((n)); \
	rm -f import/src/not_loose.txt import/src/on_dataset.txt import/src/in_archives.txt; \
	$(say) "pull_hf: $$n GRs listed: $$h PDFs here loose, $$a in $$k monthly archives (fetched when new or changed)$$(test $$((n - h - a)) -eq 0 || echo ", $$((n - h - a)) not on the dataset (make import lists them in import/src/missing.txt)")"; \
	test $$k -eq 0 || xargs -n 200 $(hf_get) < import/src/fetch.txt > /dev/null
	@for t in $(tasks); do \
	  f=LFS/mahGRs/govdocs/$(dept)/$$t/$(dept)_$${t}_files.txt; \
	  $(hf_get) govdocs/$(dept)/$$t/$(dept)_$${t}_files.txt > /dev/null 2>&1 || continue; \
	  $(listed) | cut -d/ -f2 | sort -u > import/src/months.txt; cut -d/ -f1 $$f | sort -u > import/src/have.txt; \
	  comm -12 import/src/months.txt import/src/have.txt | sed "s|.*|govdocs/$(dept)/$$t/&.zip|"; \
	done > import/src/fetch_govdocs.txt; rm -f import/src/months.txt import/src/have.txt; \
	k=$$(($$(wc -l < import/src/fetch_govdocs.txt))); $(say) "pull_hf: the tasks' GovDoc files of $$k months"; \
	test $$k -eq 0 || xargs -n 200 $(hf_get) < import/src/fetch_govdocs.txt > /dev/null
	@$(hf_get) --include "responses/$(dept)/*" > /dev/null 2>&1 || true
	@$(say) "pull_hf: the department's paid answers (responses/$(dept)/)"

# The department's own lists (flow/<dept>/common/), and every other department's sheets (with their corrections) and
# scorecard, so a name or sentence another department has translated is taken, not paid for again (orgpedia/doc
# mahgrs.md §W15), and the scorecard compares (docflow.md §N19). make import links them into import/. Its paid answers
# come with make pull_hf (responses/<dept>/).
pull_common:
	@$(say) "pull_common: $(dept)'s lists, the other departments' sheets, from $(HF_DATASET)"
	@$(hf_get) > /dev/null --include "flow/$(dept)/common/*" --include "flow/*/common/glossary/mr_en*.tsv" \
	  --include "flow/*/common/memory/mr_en*.tsv" --include "flow/*/common/scorecard.json"

# LFS/ into import/ (the listed PDFs, unique by content, the sources, the records) and into export/ (the tasks'
# earlier GovDoc files and paid answers, out of their zips); the flow's data. The tasks link their own input/.
import:
	$(run) mahdept import
	$(run) mahdept data
input: import  # the old name (a repo made before November 18)

.PHONY: $(addprefix flow/,$(tasks))
flow: $(addprefix flow/,$(tasks))
$(addprefix flow/,$(tasks)):
	$(run) make -C $@
flow/build_glossary_: flow/build_doc_
flow/translate_: flow/build_glossary_

# what a person reviews, in the browser (the task's make review; nothing is run): build_doc_'s scorecard in Studio,
# or TASK=build_glossary_ (the candidate names), TASK=translate_ (the pilot's page)
review:
	$(run) make -C flow/$(TASK) review

# build_doc_'s scorecard again (make flow makes it, as the end of build_doc_'s make), beside every other department's
scorecard:
	$(run) make -C flow/build_doc_ scorecard

export:
	$(foreach t,$(tasks),$(run) make -C flow/$t export;)
output: export  # the old name

# export/ into LFS/ (mahdept push: each task's GovDoc files a zip a month of the GR's date, govdocs/<dept>/<task>/, and
# its paid answers a zip a month they were paid for, responses/<dept>/<task>/; stored, names sorted, times fixed, so an
# unchanged month is not uploaded again), then up, with the department's lists. It refuses while a task's output/
# holds a large file of its own (make export first). It must succeed before git commit (orgpedia/doc docflow.md
# §N12). Needs HF_TOKEN with write access.
push_hf:
	@test "$(kind)" != trial || { echo "push_hf: a trial never pushes"; exit 1; }
	@test -n "$(HF_TOKEN)" || { echo "push_hf: HF_TOKEN is not set (.env)"; exit 1; }
	@test -z "$$(find flow/*/output -type f ! -name '*.status.json' ! -name set_aside.txt 2>/dev/null | head -1)" || \
	  { echo "push_hf: a task's output/ still holds files of its own (GovDoc files, lists): make export first"; exit 1; }
	$(run) mahdept push
	test ! -d LFS/mahGRs/govdocs/$(dept) || $(hf_put) LFS/mahGRs/govdocs/$(dept) govdocs/$(dept) --commit-message "$(dept): GovDoc files"
	test ! -d LFS/mahGRs/responses/$(dept) || $(hf_put) LFS/mahGRs/responses/$(dept) responses/$(dept) --commit-message "$(dept): paid responses"
	test ! -d LFS/mahGRs/flow/$(dept)/common || $(hf_put) LFS/mahGRs/flow/$(dept)/common flow/$(dept)/common --commit-message "$(dept): its lists"

# Space, for running the departments one after another (after push_hf and git commit). clean_images: the page images
# sent to IndicOCR (flow/build_doc_/logs/deferred.jsonl.files/, about 0.6 MB a page) and build_doc_'s workspace on the
# OCR workspace API (<dept>-build_doc_, its images and batches; orgpedia/doc docflow.md §P11b), kept until the run is
# done; its answers are in responses/, and make flow renders a page's image again whenever it needs one. A workspace
# not deleted (a batch still running) is said, not a failure: the API deletes it after 7 days without activity. clean_pdfs: the PDFs (import/pdfs/, import/pdfs.txt,
# LFS/mahGRs/pdfs/<dept>/: links when pull_hf had PDFS_FROM, else the archives fetched and the PDFs taken out of them),
# not while build_doc_ has GRs failed or waiting for IndicOCR (flow/build_doc_/failed.txt: they need their PDFs). With
# import/pdfs.txt gone build_doc_ does not run (make list_all pull_hf import first): translate_ still runs in its own
# folder (make -C flow/translate_), reading build_doc_'s GovDoc files in export/, never the PDFs.
clean_images:
	cd flow/build_doc_ && uv run --no-sync docflow batch src/flow.yml --delete \
	  || echo "clean_images: build_doc_'s workspace not deleted (docflow batch src/flow.yml --delete, in flow/build_doc_)"
	rm -rf flow/build_doc_/logs/deferred.jsonl flow/build_doc_/logs/deferred.jsonl.files
	@$(say) "clean_images: the page images sent to IndicOCR removed"

clean_pdfs:
	@test ! -s flow/build_doc_/failed.txt || { echo "clean_pdfs: build_doc_ has GRs failed or waiting for IndicOCR" \
	  "(flow/build_doc_/failed.txt): make flow until none is left; they are read from their PDFs"; exit 1; }
	@for p in LFS LFS/mahGRs LFS/mahGRs/pdfs LFS/mahGRs/pdfs/$(dept) import import/pdfs; do test ! -L $$p || \
	  { echo "clean_pdfs: $$p is a link (it may lead to PDFs kept elsewhere): remove what it holds by hand"; exit 1; }; done
	rm -rf import/pdfs import/pdfs.txt LFS/mahGRs/pdfs/$(dept)
	@$(say) "clean_pdfs: the PDFs and import/pdfs.txt removed; before build_doc_ runs again: make list_all pull_hf import"

check:
	$(foreach t,$(tasks),$(run) make -C flow/$t check;)
	@test -z "$$(find flow/*/output -type f ! -name '*.status.json' ! -name set_aside.txt 2>/dev/null | head -1)" || \
	  { echo "check: a task's output/ holds files of its own, not to be committed: make export, then push_hf"; exit 1; }

studio:
	$(run) make -C flow/build_doc_ studio
