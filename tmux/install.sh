#!/bin/bash -ve

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmux_version=2.6
if which tmux; then
    sudo apt-get remove -y tmux
fi
sudo apt-get -y install wget tar libevent-dev libncurses-dev
cd /tmp
wget https://github.com/tmux/tmux/releases/download/${tmux_version}/tmux-${tmux_version}.tar.gz
tar xf tmux-${tmux_version}.tar.gz
rm -f tmux-${tmux_version}.tar.gz
cd tmux-${tmux_version}
./configure
make
sudo make install
cd -
rm -rf tmux-${tmux_version}
ln -sf $DIR/tmux.conf $HOME/.tmux.conf
