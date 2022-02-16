require 'apipie_bindings'
require 'hammer_cli/ssloptions'

module HammerCLI::Apipie
  class ApiConnection < HammerCLI::AbstractConnector
    attr_reader :api

    def initialize(params, options = {})
      @logger = options[:logger]
      @api = ApipieBindings::API.new(params, HammerCLI::SSLOptions.new.get_options(params[:uri]))
      if options[:reload_cache] || (options[:use_modules_checksum] && HammerCLI::Modules.changed?)
        @api.clean_cache
        HammerCLI.clear_cache
        unless @logger.nil?
          @logger.debug 'Apipie cache was cleared'
          @logger.debug 'Completion cache was cleared'
        end
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
