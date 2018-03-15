#!/bin/bash -ve

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmux_version=2.6
apt_version=$(apt-cache policy tmux | grep Candidate | awk '{print $2}' | awk -F- '{print $1}')

if (($(echo $tmux_version | tr -d .) > $(echo $apt_version | tr -d .))); then
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
else
    sudo apt-get install tmux
fi

ln -sf $DIR/tmux.conf $HOME/.tmux.conf
