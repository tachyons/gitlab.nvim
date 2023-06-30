default:
	@grep '^[^#[:space:]].*:' Makefile

test:
	ln -nfs $(shell pwd) ~/.local/share/nvim/site/pack/vendor/start
	nvim --headless -c "PlenaryBustedDirectory spec/" -c cquit
