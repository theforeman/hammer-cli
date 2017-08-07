#
# Makefile for PO merging and MO generation. More info in the README.
#
# Run make help to list available targets
#
DOMAIN = hammer-cli
VERSION = $(shell bundle exec ruby -e 'require "rubygems"; spec = Gem::Specification::load("../hammer_cli.gemspec"); puts spec.version')
MAIN_MAKEFILE = $(shell bundle exec ruby -e 'require "hammer_cli"; puts HammerCLI::I18n.main_makefile')

include $(MAIN_MAKEFILE)
