#
# Makefile for PO merging and MO generation. More info in the README.
#
# make all-mo (default) - generate MO files
# make check - check translations using translate-tool
# make tx-update - download and merge translations from Transifex
# make clean - clean everything
#
DOMAIN = hammer-cli
VERSION = $(shell ruby -e 'require "rubygems";spec = Gem::Specification::load("../hammer_cli.gemspec");puts spec.version')
POTFILE = $(DOMAIN).pot
MOFILE = $(DOMAIN).mo
POFILES = $(shell find . -name '$(DOMAIN).po')
MOFILES = $(patsubst %.po,%.mo,$(POFILES))
POXFILES = $(patsubst %.po,%.pox,$(POFILES))
EDITFILES = $(patsubst %.po,%.edit.po,$(POFILES))
TIMESTAMPFILES = $(patsubst %.po,%.po.time_stamp,$(POFILES))

%.mo: %.po
	mkdir -p $(shell dirname $@)/LC_MESSAGES
	msgfmt -o $(shell dirname $@)/LC_MESSAGES/$(MOFILE) $<

# Generate MO files from PO files
all-mo: $(MOFILES)

# Check for malformed strings
%.pox: %.po
	msgfmt -c $<
	pofilter --nofuzzy -t variables -t blank -t urls -t emails -t long -t newlines \
		-t endwhitespace -t endpunc -t puncspacing -t options -t printf -t validchars --gnome $< > $@
	cat $@
	! grep -q msgid $@

check: $(POXFILES)

# Unify duplicate translations
uniq-po:
	for f in $(shell find ./ -name "*.po") ; do \
		msguniq $$f -o $$f ; \
	done

%.edit.po:
	touch $@

tx-pull: $(EDITFILES)
	tx pull -f
	for f in $(EDITFILES); do \
		sed -i 's/^\("Project-Id-Version: \).*$$/\1$(DOMAIN) $(VERSION)\\n"/' $$f; \
	done

# Merge .edit.po into .po
update-po:
	for f in $(EDITFILES); do \
		msgcat --use-first --no-location $$f $${f//.edit/} > $${f//.edit/}; \
	done

# Extract strings and update the .pot, prepare .edit.po files
extract-strings:
	bundle exec rake gettext:find

tx-update: extract-strings tx-pull update-po $(MOFILES)
	git commit -m "i18n - extracting new, pulling from tx" ../locale
	-echo Changes commited!

clean:
	rm -f $(EDITFILES) $(TIMESTAMPFILES)
