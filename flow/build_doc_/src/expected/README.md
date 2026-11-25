# Expected outputs

One file per sample PDF, `<name>.yml` (<name> as in output/: `<name>.govdoc.json.zst`): what a
person says the sample holds. `make expect` compares them with the export (docflow expect), on
every run, so a change that breaks a sample shows at once.

```yaml
# <name>: in the words of the person who described it
count: {<doc_type>: 1}                  # optional: how many documents of each type
key: {<doc_type>: <field>}              # optional: the field that pairs a type's documents
documents:                              # the documents to check, with the fields to check
  - doc_type: <doc_type>
    <field>: <value>
    <field>: {contains: <part of the value>}
    <field>: null                       # the field must be missing
notes: what no field says (a value taken from the parent, a field often missing)
```

A document is paired with the exported one of its type that has the same `key` field, or else with
the one at the same place among that type's. Fields not listed are not checked.
