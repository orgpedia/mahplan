# The large files

Kept out of git. `LFS/mahGRs/` holds what was pulled from the HuggingFace dataset `Orgpedia/mahGRs`
(orgpedia/doc `specs/mahgrs.md` §W6), at the dataset's own paths:

* `infos/<dept>/`: the crawler's records (urlinfos/, uploadinfos/, pdfinfos/), fetched by `make pull` for
  every department the list names
* `pdfs/<dept>/<YYYY-MM>.zip`: a month's PDFs (`<name>.pdf` inside), and `pdfs/<dept>/<dept>_files.txt`, every PDF
  the archives hold (`<YYYY-MM>/<name>.pdf`), which `make list_all` / `list_recent` list from; `make pull` fetches the
  list and the months `import/pdfs.txt` needs,
  `make import` takes out the PDFs the flow reads (into `../import/pdfs/`). A loose `pdfs/<dept>/<YYYY-MM>/<name>.pdf`
  is a link `make pull PDFS_FROM=<folder>` made, or a PDF pulled before the dataset was packed; it is used first.
* `jsons/<dept>/<task>/<YYYY-MM>.zip` and `<dept>_<task>_files.txt`: each task's JSON records packed the same way, by
  `make push` (`mahdept jsons`), from `export/<task>/`, and uploaded from here
* later: `govdocs/`, `runs/`, `indexes/`

Everything here can be deleted and pulled again. `make import` makes what `import/pdfs.txt` lists ready for the
flow. The shared lists are `../LFS/common/` (not on the dataset yet).
