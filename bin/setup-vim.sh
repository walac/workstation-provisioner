#!/bin/bash -ve

: WORK=${WORK=$HOME/work}

go get -u github.com/mdempsky/gocode
go get -u github.com/alecthomas/gometalinter

vim -e +BundleInstall +qall || :

$WORK/vimfiles/bundle/YouCompleteMe/install.py \
    --clang-completer \
    --tern-completer

vim -e +GoInstallBinaries +qall
gometalinter --install

cd $WORK/vimfiles/bundle/tern_for_vim/
npm install
cd -
