# conf/: a person's edits to this task's output

One file per GR, `<name>.pdf.edits.yml`, written by the reviewer (`make studio`; orgpedia/doc specs/studio.md) and
committed. docflow replays them on every run, so a fix made once stays made.

Edits only: what a person corrected, accepted or rejected in one GR. Nothing here changes how the flow works. Settings
are department-wide and live in `department.yml` (the department's own values) or the template's `src/flow.yml` (the
same in every department); a difficult GR goes in `flow.yml`'s `exclude`, with a reason.

Beside them, `values.yml`: the department's own values the flow puts in (`flow.yml`'s `values:`), written from
`department.yml` by `mahdept values` before every docflow command. It is committed, so the values a run used are
kept with the task; it is never edited here: a change goes in `department.yml`.
