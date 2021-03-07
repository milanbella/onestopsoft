autocmd FileType js set tabstop=2 | set shiftwidth=2 | set expandtab
autocmd FileType json set tabstop=2 | set shiftwidth=2 | set expandtab
autocmd FileType html set tabstop=2 | set shiftwidth=2 | set expandtab
autocmd FileType rescript set tabstop=2 | set shiftwidth=2 | set expandtab
autocmd FileType sql set tabstop=2 | set shiftwidth=2 | set expandtab
autocmd FileType rescript let b:match_ignorecase = 1
autocmd FileType rescript let b:match_words = '<:>,' .
    \ '<\@<=[ou]l\>[^>]*\%(>\|$\):<\@<=li\>:<\@<=/[ou]l>,' .
    \ '<\@<=dl\>[^>]*\%(>\|$\):<\@<=d[td]\>:<\@<=/dl>,' .
    \ '<\@<=\([^/][^ \t>]*\)[^>]*\%(>\|$\):<\@<=/\1>'

