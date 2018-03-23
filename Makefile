# http://clarkgrubb.com/makefile-style-guide

MAKEFLAGS += --warn-undefined-variables --no-print-directory
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:

.PHONY: help
help:
	@echo "Available make targets:"
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

############
# Machines #
############

.PHONY: work
work: ## Setup work laptop
work: i3

.PHONY: vagrant-i3
vagrant-i3: ## Setup vagrant-i3 machine
vagrant-i3: i3

#################
# Configuration #
#################

.PHONY: i3
i3:
	${MAKE} mount src=config/i3 dest=~/.config/i3
	@find /run/user/$(id -u) -wholename '*/i3/ipc-socket.*' -exec i3-msg -s {} reload \; > /dev/null

####################
# Makefile helpers #
####################

rsrc = $(shell realpath -m $(src))
rdest = $(shell realpath -m $(dest))

.PHONY: mount
mount:
	@mkdir -p $(rdest)
	@if ! grep $(rdest) /etc/fstab > /dev/null ; then sudo sh -c 'echo "$(rsrc) $(rdest) none bind 0 0" >> /etc/fstab' ; fi
	@if mount | grep $(rdest) > /dev/null ; then sudo umount $(rdest) ; fi
	@sudo mount $(rdest)
