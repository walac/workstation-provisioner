#!/bin/bash -ve

vim -e +BundleInstall +qall || :
$HOME/work/vimfiles/bundle/YouCompleteMe/install.py \
    --clang-completer \
    --gocode-completer \
    --tern-completer \
    --system-libclang
vim -e +GoInstallBinaries +qall
go get -u github.com/alecthomas/gometalinter
gometalinter --install

cd $HOME/work/vimfiles/bundle/tern_for_vim/
npm install
cd -
