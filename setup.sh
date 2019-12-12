#!/bin/bash

DOT_FILES=(.zshrc .tmux.conf)

for file in ${DOT_FILES[@]}
do
	ln -s $HOME/dotfiles/$file $HOME/$file
done

rm -rf "$HOME/Library/Application Support/Code/User/settings.json"
ln $HOME/dotfiles/vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"
