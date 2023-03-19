## design / assumptions

- notes are written in pure markdown.
- completely flat folder structure (no nested folders).
- filenames are 8 random hex chars, with `.md` extension (`xxxxxxxx.md`).
- first line of note is the title in h1 format (`# this is the title`).
- one word titles are considered a label.

## vim

```vim
let $NOTESIUM_DIR = trim(system("notesium home"))

autocmd BufRead,BufNewFile $NOTESIUM_DIR/*.md inoremap <expr> [[ fzf#vim#complete({
  \ 'source': 'notesium list --sort=mtime',
  \ 'options': '--with-nth 2.. --prompt "NotesiumInsertLink> "',
  \ 'reducer': {l->"[". split(l[0],':1: ')[1] ."](".split(l[0],':')[0].")"},
  \ 'window': {'width': 0.85, 'height': 0.85}})

command! -bang NotesiumNew
  \ execute ":e" system("notesium new")

command! -bang -nargs=* NotesiumList
  \ let prompt = '--prompt "NotesiumList> "' |
  \ let spec = {'dir': $NOTESIUM_DIR, 'options': '--with-nth 2.. '.prompt} |
  \ call fzf#vim#grep(
  \   'notesium list '.shellescape(<q-args>), 0,
  \   &columns > 79 ? fzf#vim#with_preview(spec) : spec, <bang>0)

command! -bang -nargs=* NotesiumBacklinks
  \ let prompt = '--prompt "NotesiumBacklinks> "' |
  \ let spec = {'dir': $NOTESIUM_DIR, 'options': '--with-nth 2.. '.prompt} |
  \ call fzf#vim#grep(
  \   'notesium list '.shellescape(<q-args>.' '.'--match=]('.expand("%:t").')'), 0,
  \   &columns > 79 ? fzf#vim#with_preview(spec) : spec, <bang>0)

command! -bang -nargs=* NotesiumSearch
  \ let prompt = '--prompt "NotesiumSearch> "' |
  \ let spec = {'dir': $NOTESIUM_DIR, 'options': ' --with-nth 2.. '.prompt} |
  \ call fzf#vim#grep(
  \   'notesium lines '.shellescape(<q-args>), 0,
  \   &columns > 79 ? fzf#vim#with_preview(spec, 'right', 'ctrl-/') : spec, <bang>0)

nnoremap <Leader>nn :NotesiumNew<CR>
nnoremap <Leader>nl :NotesiumList --prefix=label --sort=title --color<CR>
nnoremap <Leader>nm :NotesiumList --prefix=mtime --sort=mtime --color<CR>
nnoremap <Leader>nb :NotesiumBacklinks --sort=title<CR>
nnoremap <Leader>ns :NotesiumSearch --prefix=title --color<CR>
```
