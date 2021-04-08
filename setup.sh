#!/bin/bash -vex

: repo_dir ${repo_dir:=/vagrant}

_mkdir() {
    if ! test -d $1; then
        mkdir -p $1
    fi
}

_rm() {
    if test -e $1; then
        sudo rm -rf $1
    fi
}

if [ "$WORK" == "" ]; then
    if [ -d /work ]; then
        export WORK=/work
    else
        export WORK=$HOME/work
        _mkdir $WORK
    fi
fi

decrypt() {
    _mkdir $2
    openssl enc -d -aes-256-cbc -in $1.enc -out $2/$(basename $1) -kfile $repo_dir/passphrase.txt
}

gitconfig() {
    git config --global "$1" "$2"
}

_mkdir $WORK
_mkdir $HOME/bin

common_packages="\
    curl \
    autoconf \
    automake \
    bison \
    ccache \
    cgdb \
    cmake \
    flex \
    python3-pip \
    gdb \
    jq \
    git \
    pkg-config \
    git-svn \
    ltrace \
    bash-completion \
    binutils \
    dkms \
    gnupg2 \
    htop \
    vim \
    tmux \
    python2 \
    "

if which apt; then
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -yq
    sudo DEBIAN_FRONTEND=noninteractive apt install -yq $common_packages \
        autoconf2.13 \
        autotools-dev \
        build-essential \
        gnupg-agent \
        ssl-cert \
        unrar \
        dpkg-dev \
        language-pack-en \
        yasm \
        dnsutils \
        xz-utils
elif which dnf; then
    sudo dnf -yq up
    sudo dnf -yq install $common_packages \
        gcc \
        gcc-c++ \
        openssl
fi

# Set timezone and date/time
if which timedatactl; then
    sudo timedatectl set-timezone America/Sao_Paulo || :
    sudo timedatectl set-ntp yes || :
fi

if which systemctl; then
    sudo systemctl enable systemd-timesyncd.service || :
    sudo systemctl start systemd-timesyncd.service || :
fi

# Add /usr/local/lib to lib path
sudo cp -f $repo_dir/etc/00_ld.so.local.conf /etc/ld.so.conf.d/
sudo ldconfig

$repo_dir/openssl/install.sh

# Install go-gvm
_rm $HOME/.gvm
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

_mkdir $HOME/.ssh
for i in $repo_dir/ssh/*.enc; do
    echo $i
    decrypt ${i%.*} $HOME/.ssh
done
for i in $HOME/.ssh/*; do
    chmod 600 $i
done

for i in $repo_dir/bin/*; do
    cp -f $i -t ~/bin/
done

cp -f $repo_dir/ssh/config -t $HOME/.ssh/

for i in $repo_dir/dotfiles/*; do
    dotfile=$(basename ${i%*.enc})
    if [[ $i == *.enc ]]; then
        decrypt ${i%*.enc} $HOME
        mv $HOME/$dotfile $HOME/.$dotfile
    else
        cp -f $i $HOME/.$dotfile
    fi
done

echo "export WORK=$WORK" > $HOME/.bash_work
chmod +x $HOME/.bash_work

gitconfig user.email wander.lairson@gmail.com
gitconfig user.name 'Wander Lairson Costa'
gitconfig color.ui auto

gitconfig merge.conflictstyle diff3
gitconfig transfer.fsckobject true
gitconfig fetch.fsckobject true
gitconfig receive.fsckobject true
gitconfig core.editor vim
gitconfig format.signoff true

gitconfig "url.git@github.com:.pushInsteadOf" https://github.com/
gitconfig "url.git@github.com:.pushInsteadOf" git://github.com/

gitconfig http.sslVerify true
gitconfig http.cookiefile $HOME/.gitcookies

if ! sudo usermod -a -G docker $USER; then
    sudo groupadd docker
    sudo usermod -a -G docker $USER
fi

cd $HOME/bin

_rm git-cinnabar
git clone git://github.com/glandium/git-cinnabar
pip3 install requests
pushd git-cinnabar
if [ $(uname -p) == "x86_64" ]; then
    PATH=$PATH:$HOME/bin/git-cinnabar git cinnabar download
fi
popd

nvm_version=v0.35.3
if [ $(uname -p) == "x86_64" ]; then
    node_version=node
else
    # last node version that provides 32 bits binaries
    node_version=v9.11.2
fi
curl -o- https://raw.githubusercontent.com/creationix/nvm/$nvm_version/install.sh | bash
source $HOME/.nvm/nvm.sh
nvm install $node_version
nvm use $node_version
npm install -g yarn eslint_d

cd $WORK
_rm vimfiles
git clone git://github.com/walac/vimfiles
git -C $WORK/vimfiles submodule update --init
cp -f $repo_dir/vim/tern-project $HOME/.tern-project
ln -sf $WORK/vimfiles/vimrc $HOME/.vimrc
ln -sf $WORK/vimfiles $HOME/.vim

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo cp $repo_dir/locales/locale /etc/default

if which locale-gen; then
    sudo locale-gen
elif which localectl; then
    localectl set-locale LANG=$LANG
fi

decrypt $repo_dir/gnupg/private-gpg.key $HOME
# If we fail to import, check if it is not because we already imported the key
if ! gpg --import --batch < $HOME/private-gpg.key; then
    if ! gpg --import --batch < $HOME/private-gpg.key 2>&1 | egrep '(already in secret keyring)|(not changed)'; then
        exit 1
    fi
fi
rm -f $HOME/private-gpg.key
cp $repo_dir/gnupg/public-gpg.key ~/.gnupg
gpg --import-ownertrust < $repo_dir/gnupg/ownertrust.txt

signingkey=$(gpg --list-secret-keys --keyid-format LONG wander.lairson@gmail.com \
    | grep sec \
    | awk '{print $2}' \
    | awk -F/ '{print $2}'
)

gitconfig commit.gpgSign true
gitconfig tag.gpgSign true
gitconfig user.signingkey $signingkey

if which apt; then
    sudo apt -yq autoremove
elif which dnf; then
    sudo dnf -yq autoremove
fi
#sudo dpkg-reconfigure --priority=low unattended-upgrades
