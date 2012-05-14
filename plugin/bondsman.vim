" File:        bondsman.vim
" Description: Git status information for your statusline from Fugitive
" Maintainer:  Alfredo Deza <alfredodeza AT gmail.com>
" License:     MIT
"============================================================================


autocmd BufWritePost,BufReadPost,BufNewFile,BufEnter * call s:SetGitModified()

function! s:SetGitModified() abort
  if !exists('b:git_dir')
    return ''
  endif
  let repo_name = RepoHead()
  let modified = GitIsModified() ? '*' : ''
  let b:git_statusline = '['.repo_name.modified.']'
endfunction

function! FindGit(type) abort
    let found = finddir(".git", ".;")
    if (found !~ '.git')
        return ""
    endif
    " Return the actual directory where .git is found
    if a:type == "dir"
        return fnamemodify(found, ":h")
    else
        return found
    endif
endfunction

function! GitIsModified() abort
    let rvalue = 0
    " First try to see if we actually have a .git dir
    let has_git = FindGit('dir')
    if (has_git == "")
        return rvalue
    else
        " this can get really expensive if we are on a large
        " repository, which is why we call it only at certain times
        " and not always all the time
        let original_dir = getcwd()
        if original_dir
            exe "cd " . has_git
            let cmd = "git status -s 2> /dev/null""
            let out = system(cmd)
            if out != ""
                let rvalue = 1
            endif
            " Finally get back to where we initially where
            exe "cd " . original_dir
            return rvalue
        else
            return ''
    endif
endfunction

function! RepoHead() abort
  let path = FindGit('repo') . '/HEAD'
  if ! filereadable(path)
      return 'NoBranch'
  endif
  let repo_name = ''
  let repo_line =  readfile(path)[0]

  if repo_line =~# '^ref: '
    let repo_name .= substitute(repo_line, '\v^(.*)/','', '')
  elseif repo_line =~# '^\x\{40\}$'
    let repo_name .= repo_line[0:7]
  endif
  return repo_name
endfunction

function! GitStatusline() abort
  " Note: Works just as long as fugitive is installed
  " should remove the depedency
  if exists('b:git_statusline')
      return b:git_statusline
  endif
  if !exists('b:git_dir')
      return ''
  else
      let repo_name = RepoHead()
      return '['.repo_name.']'
  endif
  return ''
endfunction

