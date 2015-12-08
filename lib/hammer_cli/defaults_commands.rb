require 'hammer_cli'
require 'yaml'
module HammerCLI
  class BaseDefaultsProvider
    def self.plugin_name
      self.name.split('::').first.gsub(/^HammerCLI/, '').underscore
    end

    def self.register_provider
      HammerCLI.defaults.register_provider(self)
    end

    def self.support?
      raise NotImplementedError
    end

    def self.supported_defaults
      raise NotImplementedError
    end

    def self.get_defaults
      raise NotImplementedError
    end
  end

  class DefaultsCommand < HammerCLI::AbstractCommand
    class ProvidersDefaultsCommand < HammerCLI::DefaultsCommand
      command_name 'providers'
      desc _('List all the providers')

      def execute
        data = context[:defaults].providers.map do |key, val|
          {
            :provider => key.to_s,
            :defaults => (val.supported_defaults || ['*']).map(&:to_s)
          }
        end

        fields = HammerCLI::Output::Dsl.new.build do
          field :provider, _('Provider')
          field :defaults, _('Supported defaults'), Fields::List
        end

        definition = HammerCLI::Output::Definition.new
        definition.append(fields)

        print_collection(definition, data)
        HammerCLI::EX_OK
      end

      def adapter
        @context[:adapter] || :table
      end
    end

    class ListDefaultsCommand < HammerCLI::DefaultsCommand
      command_name 'list'
      desc _('List all the default parameters')

      def execute
        data = context[:defaults].defaults_settings.map do |key, val|
          {
            :parameter => key.to_s,
            :value     => val[:provider] ? "Provided by: " + val[:provider].to_s.capitalize : val[:value]
          }
        end

        fields = HammerCLI::Output::Dsl.new.build do
          field :parameter, _('Parameter')
          field :value, _('Value'), Fields::List
        end

        definition = HammerCLI::Output::Definition.new
        definition.append(fields)

        print_collection(definition, data)
        HammerCLI::EX_OK
      end

      def adapter
        @context[:adapter] || :table
      end
    end

    class DeleteDefaultsCommand < HammerCLI::DefaultsCommand
      command_name 'delete'

      desc _('Delete a default param')
      option "--param-name", "OPTION_NAME", _("The name of the default option"), :required => true

      def execute
        if context[:defaults].defaults_settings && context[:defaults].defaults_settings[option_param_name.to_sym]
          context[:defaults].delete_default_from_conf(option_param_name.to_sym)
          param_deleted(option_param_name)
        else
          variable_not_found
        end
        HammerCLI::EX_OK
      end
    end

    class AddDefaultsCommand < HammerCLI::DefaultsCommand
      command_name 'add'

      desc _('Add a default parameter to config')
      option "--param-name", "OPTION_NAME", _("The name of the default option (e.g. organization_id)."), :required => true
      option "--param-value", "OPTION_VALUE", _("The value for the default option")
      option "--plugin-name", "OPTION_PLUGIN_NAME", _("The name of the provider providing the value. For list available providers see `hammer defaults providers`.")

      def execute
        if option_plugin_name.nil? && option_param_value.nil? || !option_plugin_name.nil? && !option_param_value.nil?
          bad_input
          HammerCLI::EX_USAGE
        else
          if option_plugin_name
            namespace = option_plugin_name
            if !context[:defaults].providers.key?(namespace)
              plugin_prob_message(namespace)
              return HammerCLI::EX_USAGE
            elsif !context[:defaults].providers[namespace].support?(option_param_name)
              defaults_not_supported_by_provider
              return HammerCLI::EX_CONFIG
            end
          end
          context[:defaults].add_defaults_to_conf({option_param_name => option_param_value}, namespace)
          added_default_message(option_param_name.to_s, option_param_value)
          HammerCLI::EX_OK
        end
      rescue Defaults::DefaultsError, SystemCallError => e
        print_message(e.message)
        HammerCLI::EX_CONFIG
      end
    end

    def added_default_message(key, value)
      print_message(_("Added %{key_val} default-option with value that will be generated from the server.") % {:key_val => key.to_s}) if value.nil?
      print_message(_("Added %{key_val} default-option with value %{val_val}.") % {:key_val => key.to_s, :val_val => value.to_s}) unless value.nil?
    end

    def plugin_prob_message(namespace)
      print_message(_("Provider #{namespace} was not found. See `hammer defaults providers` for available providers."))
    end

    def defaults_not_supported_by_provider
      print_message(_("The param name is not supported by provider. See `hammer defaults providers` for supported params."))
    end

    def param_deleted(param)
      print_message(_("%{param} was deleted successfully.") % {:param => param.to_s})
    end

    def bad_input
      print_message(_("You must specify value or a provider name, cant specify both."))
    end

    def variable_not_found
      print_message(_("Couldn't find the requested param in %s.") % context[:defaults].send(:path))
    end

    autoload_subcommands
  end
end

