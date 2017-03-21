require 'apipie_bindings'
require 'hammer_cli/ssloptions'

module HammerCLI::Apipie
  class ApiConnection < HammerCLI::AbstractConnector
    attr_reader :api

    def initialize(params, options = {})
      @logger = options[:logger]
      @api = ApipieBindings::API.new(params, HammerCLI::SSLOptions.get_options)
      if options[:reload_cache]
        @api.clean_cache
        @logger.debug 'Apipie cache was cleared' unless @logger.nil?
      end
    end

    def resources
      @api.resources
    end

    def resource(resource_name)
      @api.resource(resource_name)
    end

    def has_resource?(resource_name)
      @api.has_resource?(resource_name)
    end
  end
end
