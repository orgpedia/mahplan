# conf/: a person's edits to this task's output

One file per GR, `<name>.pdf.edits.yml`, written by the reviewer and committed: corrections to a translation or to
a name found. docflow replays them on every run. Edits only; settings are department-wide (`department.yml`, the
template's `src/flow.yml`). A correction to a name's English for every GR goes in the glossary's corrections
(`mahdept glossary review --take`), not here.

Beside them, `values.yml`: the department's own values the flow puts in (`flow.yml`'s `values:`), written from
`department.yml` by `mahdept values` before every docflow command. It is committed, so the values a run used are
kept with the task; it is never edited here: a change goes in `department.yml`.
