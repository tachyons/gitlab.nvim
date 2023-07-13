LUACHECK := $(shell command -v luacheck 2> /dev/null)
STYLUA := $(shell command -v stylua 2> /dev/null)

default:
	@echo "The folllowing are the available make targets that can be run:\n"
	@grep '^[^#[:space:]].*:' Makefile

test_all: test lint

test:
	@ln -nfs $(shell pwd) ~/.local/share/nvim/site/pack/vendor/start
	@nvim --headless -c "PlenaryBustedDirectory spec" -c cquit

format:
ifdef STYLUA
	@${STYLUA} lua/ plugin/ spec/
else
	$(error "ERROR: stylua is not installed, run `asdf install && asdf reshim stylua`.")
endif

lint:
ifdef LUACHECK
	${LUACHECK} lua/ plugin/ spec/
else
	$(error "ERROR: luacheck is not installed, run `asdf install && asdf reshim lua && luarocks install luacheck`.")
endif
ifdef STYLUA
	${STYLUA} --check lua/ plugin/ spec/
else
	$(error "ERROR: stylua is not installed, run `asdf install && asdf reshim stylua`.")
endif
