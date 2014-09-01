ifeq ($(shell which erl),)
$(error Can't find Erlang executable 'erl')
exit 1
endif
PROJECT = loise
LIB = $(PROJECT)
DEPS = ./deps
BIN_DIR = ./bin
EXPM = $(BIN_DIR)/expm

SOURCE_DIR = ./src
OUT_DIR = ./ebin
TEST_DIR = ./test
TEST_OUT_DIR = ./.eunit
SCRIPT_PATH=$(DEPS)/lfe/bin:.:./bin:"$(PATH)":/usr/local/bin
ERL_LIBS=$(shell $(LFETOOL) info erllibs):.:..
EMPTY =
ifeq ($(shell which lfetool),$EMPTY)
	LFETOOL=$(BIN_DIR)/lfetool
else
	LFETOOL=lfetool
endif
OS := $(shell uname -s)
ifeq ($(OS),Linux)
        HOST=$(HOSTNAME)
endif
ifeq ($(OS),Darwin)
        HOST = $(shell scutil --get ComputerName)
endif

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(LFETOOL): $(BIN_DIR)
	@[ -f $(LFETOOL) ] || \
	curl -L -o ./lfetool https://raw.github.com/lfe/lfetool/master/lfetool && \
	chmod 755 ./lfetool && \
	mv ./lfetool $(BIN_DIR)

get-version:
	@PATH=$(SCRIPT_PATH) lfetool info version

$(EXPM): $(BIN_DIR)
	@[ -f $(EXPM) ] || \
	PATH=$(SCRIPT_PATH) lfetool install expm $(BIN_DIR)

get-deps:
	@echo "Getting dependencies ..."
	@which rebar.cmd >/dev/null 2>&1 && rebar.cmd get-deps || rebar get-deps
	@PATH=$(SCRIPT_PATH) lfetool update deps

clean-ebin:
	@echo "Cleaning ebin dir ..."
	@rm -f $(OUT_DIR)/*.beam

clean-eunit:
	@PATH=$(SCRIPT_PATH) lfetool tests clean

compile: get-deps clean-ebin
	@echo "Compiling project code and dependencies ..."
	@which rebar.cmd >/dev/null 2>&1 &&
	ERL_LIBS=$(ERL_LIBS) rebar.cmd compile || \
	ERL_LIBS=$(ERL_LIBS) rebar compile

compile-no-deps: clean-ebin
	@echo "Compiling only project code ..."
	@which rebar.cmd >/dev/null 2>&1 && \
	ERL_LIBS=$(ERL_LIBS) rebar.cmd compile skip_deps=true || \
	ERL_LIBS=$(ERL_LIBS) rebar compile skip_deps=true

compile-tests:
	@PATH=$(SCRIPT_PATH) ERL_LIBS=$(ERL_LIBS) lfetool tests build

repl: compile
	@which clear >/dev/null 2>&1 && clear || printf "\033c"
	@echo "Starting shell ..."
	@PATH=$(SCRIPT_PATH) ERL_LIBS=$(ERL_LIBS) lfetool repl

repl-no-deps: compile-no-deps
	@which clear >/dev/null 2>&1 && clear || printf "\033c"
	@echo "Starting shell ..."
	@PATH=$(SCRIPT_PATH) ERL_LIBS=$(ERL_LIBS) lfetool repl

clean: clean-ebin clean-eunit
	@which rebar.cmd >/dev/null 2>&1 && rebar.cmd clean || rebar clean

check-unit-only:
	@PATH=$(SCRIPT_PATH) ERL_LIBS=$(ERL_LIBS) lfetool tests unit

check-integration-only:
	@PATH=$(SCRIPT_PATH) ERL_LIBS=$(ERL_LIBS) lfetool tests integration

check-system-only:
	@PATH=$(SCRIPT_PATH) ERL_LIBS=$(ERL_LIBS) lfetool tests system

check-unit-with-deps: get-deps compile compile-tests check-unit-only
check-unit: compile-no-deps check-unit-only
check-integration: compile check-integration-only
check-system: compile check-system-only
check-all-with-deps: compile check-unit-only check-integration-only \
	check-system-only
check-all: get-deps compile-no-deps
	@PATH=$(SCRIPT_PATH) ERL_LIBS=$(ERL_LIBS) lfetool tests all

check: check-unit-with-deps

check-travis: $(LFETOOL) check

push-all:
	@echo "Pusing code to github ..."
	git push --all
	git push upstream --all
	git push --tags
	git push upstream --tags

install: compile
	@echo "Installing lmug-yaws ..."
	@PATH=$(SCRIPT_PATH) lfetool install lfe

upload: $(EXPM) get-version
	@echo "Preparing to upload lmug-yaws ..."
	@echo
	@echo "Package file:"
	@echo
	@cat package.exs
	@echo
	@echo "Continue with upload? "
	@read
	$(EXPM) publish
