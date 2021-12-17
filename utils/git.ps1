function repo () { cd $(Join-Path $(ghq root) $(ghq list | fzf).Replace('/', '\')) }
