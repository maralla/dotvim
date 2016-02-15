#!/usr/bin/env bash

mkdir -p ~/.vim/autoload
mkdir -p ~/.vim/mysnippets

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
