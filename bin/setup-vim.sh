#!/bin/bash -ve

: WORK=${WORK=$HOME/work}

vim -e +BundleInstall +qall || :
vim -e +"CocInstall \
    coc-marketplace \
    coc-json \
    coc-cmake \
    coc-explorer \
    coc-python \
    coc-rls \
    coc-yaml \
    coc-clangd \
    coc-tsserver \
    "

$WORK/vimfiles/bundle/YouCompleteMe/install.py --go-completer

vim -e +GoInstallBinaries +qall

cd $WORK/vimfiles/bundle/tern_for_vim/
npm install
cd -
