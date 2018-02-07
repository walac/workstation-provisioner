#!/bin/bash -vex

: repo_dir ${repo_dir:=/vagrant}

_mkdir() {
    if ! test -d $1; then
        mkdir -p $1
    fi
}

_rm() {
    if test -e $1; then
        rm -rf $1
    fi
}

decrypt() {
    _mkdir $2
    openssl enc -d -aes-256-cbc -in $1.enc -out $2/$(basename $1) -kfile $repo_dir/passphrase.txt
}

gitconfig() {
    git config --global "$1" "$2"
}

_mkdir $HOME/work
_mkdir $HOME/bin

sudo add-apt-repository -y ppa:gophers/archive
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
    autoconf \
    autoconf2.13 \
    automake \
    autotools-dev \
    awscli \
    bison \
    ccache \
    cgdb \
    cmake \
    dpkg-dev \
    flex \
    libclang-5.0-dev \
    gdb \
    exuberant-ctags \
    git \
    pkg-config \
    golang-1.9-go \
    git-svn \
    ltrace \
    mercurial \
    yasm \
    bash-completion \
    bcrypt \
    binutils \
    build-essential \
    dkms \
    dnsutils \
    gnupg2 \
    gnupg-agent \
    htop \
    libusb-0.1-4 \
    libusb-1.0-0-dev \
    ssl-cert \
    unrar \
    vim \
    libpython2.7-dev \
    docker.io \
    language-pack-en \
    xz-utils

_mkdir $HOME/.ssh
for i in $repo_dir/ssh/*.enc; do
    echo $i
    decrypt ${i%.*} $HOME/.ssh
done
for i in $HOME/.ssh/*; do
    chmod 600 $i
done

cp $repo_dir/ssh/config $HOME/.ssh/

for i in $repo_dir/dotfiles/*; do
    dotfile=$(basename ${i%*.enc})
    if [[ $i == *.enc ]]; then
        decrypt ${i%*.enc} $HOME
        mv $HOME/$dotfile $HOME/.$dotfile
    else
        cp $i $HOME/.$dotfile
    fi
done

bugzilla_apikey=$(cat $HOME/.bashrc_secrets \
    | grep BUGZILLA_APIKEY \
    | awk -F= '{print $2}'
)

gitconfig user.email wcosta@mozilla.com
gitconfig user.name 'Wander Lairson Costa'
gitconfig color.ui auto

gitconfig bz.browser firefox3
gitconfig bz.apikey $bugzilla_apikey
gitconfig bz.username wcosta@mozilla.com

gitconfig merge.conflictstyle diff3
gitconfig transfer.fsckobject true
gitconfig fetch.fsckobject true
gitconfig receive.fsckobject true
gitconfig mozreview.nickname wcosta

gitconfig "url.git@github.com.pushInsteadOf" https://github.com/
gitconfig "url.git@github.com.pushInsteadOf" git://github.com/

gitconfig http.sslVerify true
gitconfig http.cookiefile $HOME/.gitcookies

gitconfig gpg.program gpg2

sudo usermod -a -G docker $USER

cd $HOME/bin
_rm moz-git-tools
git clone git://github.com/mozilla/moz-git-tools
git -C moz-git-tools submodule update --init
_rm git-cinnabar
git clone git://github.com/glandium/git-cinnabar

nvm_version=v0.33.8
curl -o- https://raw.githubusercontent.com/creationix/nvm/$nvm_version/install.sh | bash
source $HOME/.nvm/nvm.sh
nvm install node
nvm use node
npm install -g yarn eslint_d

cd $HOME/work
_rm vimfiles
git clone git://github.com/walac/vimfiles
git -C $HOME/work/vimfiles submodule update --init
cp $repo_dir/vim/setup-vim.sh $HOME/bin
cp $repo_dir/vim/tern-project $HOME/.tern-project
cp $repo_dir/vim/ycm_extra_conf.py $HOME/.ycm_extra_conf.py
! test -L ~/.vimrc || rm -f ~/.vimrc
! test -L ~/.vim || rm -f ~/.vim
ln -s $HOME/work/vimfiles/vimrc $HOME/.vimrc
ln -s $HOME/work/vimfiles $HOME/.vim

decrypt $repo_dir/aws/credentials $HOME/.aws/

decrypt $repo_dir/gnupg/private-gpg.key $HOME
# If we fail to import, check if it is not because we already imported the key
if ! gpg --import < $HOME/private-gpg.key; then
    if ! gpg --import < $HOME/private-gpg.key 2>&1 | grep 'already in secret keyring'; then
        exit 1
    fi
fi
rm -f $HOME/private-gpg.key
cp $repo_dir/gnupg/public-gpg.key ~/.gnupg
gpg --import-ownertrust < $repo_dir/gnupg/ownertrust.txt

signingkey=$(gpg --list-secret-keys --keyid-format LONG wcosta@mozilla.com \
    | grep sec \
    | awk '{print $2}' \
    | awk -F/ '{print $2}'
)

$repo_dir/tmux/install.sh

gitconfig commit.gpgSign true
gitconfig user.signingkey $signingkey

sudo apt-get autoremove
#sudo dpkg-reconfigure --priority=low unattended-upgrades
