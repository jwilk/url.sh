# Copyright © 2022 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

.PHONY: all
all: ;

.PHONY: test
test:
	prove -v

.PHONY: test-x
test-x:
	URL_SH_X_TESTING=1 prove -v t/paste-*.t

shell = *
.PHONY: test-xvfb
test-xvfb:
	URL_SH_X_TESTING=1 xvfb-run prove -v t/paste-$(shell).t

# vim:ts=4 sts=4 sw=4 noet
