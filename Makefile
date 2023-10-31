.PHONY: default test_all test test_file format lint luacheck stylua

LUACHECK := $(shell command -v luacheck 2> /dev/null)
LUACHECK_MISSING_ERROR := ERROR: luacheck is not installed, run `asdf plugin add lua ; asdf install && asdf reshim lua && luarocks install luacheck`

STYLUA := $(shell command -v stylua 2> /dev/null)
STYLUA_ERROR := ERROR: stylua is not installed, run `asdf plugin add stylua ; asdf install && asdf reshim stylua`

default:
	@echo "The folllowing are the available make targets that can be run:\n"
	@grep '^[^#[:space:]].*:' Makefile

test_all: test lint

ifndef SPEC
override SPEC = spec
endif

PLENARY_PATH ?= ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim
$(PLENARY_PATH):
	git clone --depth 1 https://github.com/nvim-lua/plenary.nvim ${PLENARY_PATH}

test: | $(PLENARY_PATH)
	@nvim --clean --headless \
		-c "source spec/init.lua" \
		-c "PlenaryBustedDirectory ${SPEC}" \
		-c cquit

test_file: | $(PLENARY_PATH)
	@nvim --clean --headless \
		-c "source spec/init.lua" \
		-c "PlenaryBustedFile $(FILE)" \
		-c cquit

ifndef LINT_FILES
override LINT_FILES = lua/ plugin/ spec/
endif

format:
ifdef STYLUA
	@${STYLUA} ${LINT_FILES}
else
	$(error "${STYLUA_MISSING_ERROR}"}
endif

lint: luacheck stylua

luacheck:
ifdef LUACHECK
	${LUACHECK} ${LINT_FILES}
else
	$(error "${LUACHECK_MISSING_ERROR}")
endif

stylua:
ifdef STYLUA
	${STYLUA} --check ${LINT_FILES}
else
	$(error "${STYLUA_ERROR}")
endif

lint-lsp-deps: lsp/package-lock.json
	@echo 'Checking for uncommitted changes in lsp/package.json or lsp/package-lock.json.'
	git diff --exit-code lsp/package-lock.json lsp/package.json

lsp/package.json:
	./lsp/scripts/npm-wrapper install

lsp/package-lock.json: lsp/package.json

.PHONY: lsp/package.json lsp/package-lock.json lint-lsp-deps
