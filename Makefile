PROJECT = emqx_auth_clientid
PROJECT_DESCRIPTION = EMQ X Authentication with ClientId/Password

CUR_BRANCH := $(shell git branch | grep -e "^*" | cut -d' ' -f 2)
BRANCH := $(if $(filter $(CUR_BRANCH), master develop), $(CUR_BRANCH), develop)

DEPS = emqx_passwd clique minirest
dep_emqx_passwd = git-emqx https://github.com/emqx/emqx-passwd v1.0
dep_clique      = git-emqx https://github.com/emqx/clique v0.3.11
dep_minirest = git-emqx https://github.com/emqx/minirest v0.2.2

BUILD_DEPS = emqx cuttlefish
dep_emqx = git-emqx https://github.com/emqx/emqx $(BRANCH)
dep_cuttlefish = git-emqx https://github.com/emqx/cuttlefish v2.2.1
dep_emqx_management = git-emqx https://github.com/emqx/emqx-management $(BRANCH)

TEST_DEPS = emqx_ct_helper emqx_management
dep_emqx_ct_helper = git-emqx https://github.com/emqx/emqx-ct-helpers v1.0
dep_emqx_management = git-emqx https://github.com/emqx/emqx-management $(BRANCH)

NO_AUTOPATCH = cuttlefish

ERLC_OPTS += +debug_info

TEST_ERLC_OPTS += +debug_info

COVER = true

$(shell [ -f erlang.mk ] || curl -s -o erlang.mk https://raw.githubusercontent.com/emqx/erlmk/master/erlang.mk)

include erlang.mk

CUTTLEFISH_SCRIPT = _build/default/lib/cuttlefish/cuttlefish

app.config: $(CUTTLEFISH_SCRIPT) etc/emqx_auth_clientid.conf
	$(verbose) $(CUTTLEFISH_SCRIPT) -l info -e etc/ -c etc/emqx_auth_clientid.conf -i priv/emqx_auth_clientid.schema -d data

$(CUTTLEFISH_SCRIPT): rebar-deps
	@if [ ! -f cuttlefish ]; then make -C _build/default/lib/cuttlefish; fi

distclean::
	@rm -rf _build cover deps logs log data
	@rm -f rebar.lock compile_commands.json cuttlefish

rebar-deps:
	rebar3 get-deps

rebar-clean:
	@rebar3 clean

rebar-compile: rebar-deps
	rebar3 compile

rebar-ct: app.config
	rebar3 ct

rebar-xref:
	@rebar3 xref

