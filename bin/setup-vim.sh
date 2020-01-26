#!/bin/bash -ve

: WORK=${WORK=$HOME/work}

vim -e +BundleInstall +qall || :

$WORK/vimfiles/bundle/YouCompleteMe/install.py \
    --clang-completer \
    --clangd-completer \
    --tern-completer \
    --ts-completer \
    --go-completer \
    --rust-completer

cd $WORK/vimfiles/bundle/tern_for_vim/
npm install
cd -
