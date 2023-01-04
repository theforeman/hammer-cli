#
# Makefile for PO merging and MO generation. More info in the README.
#
# Run make help to list available targets
#
DOMAIN = hammer-cli
VERSION = $(shell ruby -rrubygems -e 'puts Gem::Specification::load(Dir.glob("../*.gemspec").first).version')
MAIN_MAKEFILE = $(shell bundle exec ruby -rhammer_cli -e 'puts HammerCLI::I18n.main_makefile')

include $(MAIN_MAKEFILE)
