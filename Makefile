# Makefile for terra-mode

VERSION="$(shell grep Version terra-mode.el | cut -f 3- -d " " | sed -e 's/^[ \t]*//')"
DISTFILE = terra-mode-$(VERSION).zip

# EMACS value may be overridden
EMACS?=emacs
EMACS_MAJOR_VERSION=$(shell $(EMACS) -batch -eval '(princ emacs-major-version)')
TERRA_MODE_ELC=terra-mode.$(EMACS_MAJOR_VERSION).elc

EMACS_BATCH=cask exec $(EMACS) --batch -Q

default:
	@echo version is $(VERSION)

%.$(EMACS_MAJOR_VERSION).elc: %.elc
	cp $< $@

%.elc: %.el
	$(EMACS_BATCH) -f batch-byte-compile $<

compile: $(TERRA_MODE_ELC)

dist:
	rm -f $(DISTFILE) && \
	git archive --format=zip -o $(DISTFILE) --prefix=terra-mode/ HEAD

.PHONY: test-compiled test-uncompiled
# check both regular and compiled versions
test: test-compiled test-uncompiled

test-compiled: $(TERRA_MODE_ELC)
	EMACS=$(EMACS) cask exec buttercup -l $(TERRA_MODE_ELC)

test-uncompiled:
	EMACS=$(EMACS) cask exec buttercup -l terra-mode.el

release:
	git fetch && \
	git diff remotes/origin/master --exit-code && \
	git tag -a -m "Release tag" rel-$(VERSION) && \
	woger terra-l terra-mode terra-mode "release $(VERSION)" "Emacs major mode for editing Terra files" release-notes-$(VERSION) http://github.com/StanfordLegion/terra-mode && \
	git push origin master
	@echo 'Send update to ELPA!'


tryout:
	cask exec $(EMACS) -Q -l init-tryout.el test.terra
