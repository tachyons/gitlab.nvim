.PHONY: default integration_test test format lint luacheck stylua

LUACHECK := $(shell command -v luacheck 2> /dev/null)
LUACHECK_MISSING_ERROR := ERROR: luacheck is not installed, run `asdf plugin add lua ; asdf install && asdf reshim lua && luarocks install luacheck`

STYLUA := $(shell command -v stylua 2> /dev/null)
STYLUA_ERROR := ERROR: stylua is not installed, run `asdf plugin add stylua ; asdf install && asdf reshim stylua`

default:
	@echo "The folllowing are the available make targets that can be run:\n"
	@grep '^[^#[:space:]].*:' Makefile

PLENARY_PATH ?= ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim
$(PLENARY_PATH):
	git clone --depth 1 https://github.com/nvim-lua/plenary.nvim ${PLENARY_PATH}

integration_test: clean-lsp-deps | $(PLENARY_PATH)
	@env RUN_INTEGRATION_TESTS=true nvim --clean --headless \
		-c "source spec/init.lua" \
		-c "PlenaryBustedDirectory $${SPEC:-spec/integration}" \
		-c cquit

test: | $(PLENARY_PATH)
	@nvim --clean --headless \
		-c "source spec/init.lua" \
		-c "PlenaryBustedDirectory $${SPEC:-spec}" \
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

clean-lsp-deps:
	rm -rf node_modules

lint-lsp-deps: package-lock.json
	@echo 'Checking for uncommitted changes in package.json or package-lock.json.'
	git diff --exit-code package-lock.json package.json

package.json:
	npm install --omit=peer

package-lock.json: package.json

.PHONY: clean-lsp-deps package.json package-lock.json lint-lsp-deps
