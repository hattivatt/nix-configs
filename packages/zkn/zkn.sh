#!/bin/bash


name=${1:-"!new-$(date +"%d%m%Y-%H%M")"}

nvim -c "lua vim.defer_fn(function() vim.cmd('Obsidian template zk_template'); vim.api.nvim_win_set_cursor(0, {14, 0}) end, 100)" /home/hattivatt/Notes/ObsidianNotes/zettelkasten/"${name}".md
