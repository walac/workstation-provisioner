#!/bin/bash -ve

go get -u github.com/mdempsky/gocode
go get -u github.com/alecthomas/gometalinter

vim -e +BundleInstall +qall || :

$HOME/work/vimfiles/bundle/YouCompleteMe/install.py \
    --clang-completer \
    --tern-completer \
    --system-libclang

vim -e +GoInstallBinaries +qall
gometalinter --install

cd $HOME/work/vimfiles/bundle/tern_for_vim/
npm install
cd -
