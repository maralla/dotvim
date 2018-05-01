#!/usr/bin/env bash


log() {
    echo -e "\033[1m\033[32mINFO:\033[0m $1"
}


if [ -d "$HOME/.vim" ]
then
    ts=$(date +"%Y%m%d@%H:%M:%S")
    log "Make backup of '\$HOME/.vim' to '\$HOME/.vim.$ts'"
    mv $HOME/{.vim,.vim.$ts}
fi

log "Clone maralla/dotvim..."
git clone https://github.com/maralla/dotvim.git $HOME/.vim
log "Install packs..."
(cd $HOME/.vim && pack install)
log "Done"
