require File.join(File.dirname(__FILE__), 'options')
require File.join(File.dirname(__FILE__), 'resource')

module HammerCLI::Apipie

  class Command < HammerCLI::AbstractCommand

    include HammerCLI::Apipie::Resource
    include HammerCLI::Apipie::Options

  end
end
