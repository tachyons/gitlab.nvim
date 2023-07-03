LUACHECK := $(shell command -v luacheck 2> /dev/null)

default:
	@grep '^[^#[:space:]].*:' Makefile

test_all: test lint

test:
	ln -nfs $(shell pwd) ~/.local/share/nvim/site/pack/vendor/start
	nvim --headless -c "PlenaryBustedDirectory spec/" -c cquit

lint:
ifdef LUACHECK
	@${LUACHECK} lua/ plugin/ spec/
else
	$(error "ERROR: luacheck is not installed, run `asdf install && asdf reshim lua && luarocks install luacheck`.")
endif
