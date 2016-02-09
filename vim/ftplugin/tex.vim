set wrap
set nolist

" Vim LaTeX Suite
let g:Tex_MultipleCompileFormats = 'pdf,bib,pdf'
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_ViewRule_pdf = 'evince'

" Build: pdf, pdf, biber, pdf, open in evince.
nnoremap <Leader>b :!pdflatex main.tex<cr><cr>:!pdflatex main.tex<cr><cr>:!biber main<cr>:!pdflatex main.tex<cr><cr>:!evince main.pdf &<cr><cr>
