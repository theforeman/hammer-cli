
module HammerCLI

  module Subcommand

    class Definition < Clamp::Subcommand::Definition

      def initialize(names, description, subcommand_class, options = {})
        @names = Array(names)
        @description = description
        @subcommand_class = subcommand_class
        @hidden = options[:hidden]
        @warning = options[:warning]
        super(@names, @description, @subcommand_class)
      end

      def hidden?
        @hidden
      end

      def subcommand_class
        @warning ||= @subcommand_class.warning
        warn(@warning) if @warning
        @subcommand_class
      end

      def help
        names = HammerCLI.context[:full_help] ? @names.join(", ") : @names.first
        [names, description]
      end

      attr_reader :warning
    end

    class LazyDefinition < Definition

      def initialize(names, description, subcommand_class_name, path, options = {})
        super(names, description, subcommand_class_name, options)
        @loaded = false
        @path = path
      end

      def loaded?
        @loaded
      end

      def subcommand_class
        unless @loaded
          require @path
          @loaded = true
          @constantized_class = @subcommand_class.constantize
        end
        @warning ||= @constantized_class.warning
        warn(@warning) if @warning
        @constantized_class
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end



    module ClassMethods
      def remove_subcommand(name)
        self.recognised_subcommands.delete_if do |sc|
          if sc.is_called?(name)
            logger.info "subcommand #{name} (#{sc.subcommand_class}) was removed."
            true
          else
            false
          end
        end
      end

      def subcommand!(name, description, subcommand_class = self, options = {}, &block)
        remove_subcommand(name)
        subcommand(name, description, subcommand_class, options, &block)
        logger.info "subcommand #{name} (#{subcommand_class}) was created."
      end

      def subcommand(name, description, subcommand_class = self, options = {}, &block)
        definition = Definition.new(name, description, subcommand_class, options)
        define_subcommand(name, subcommand_class, definition, &block)
      end

      def lazy_subcommand(name, description, subcommand_class_name, path, options = {})
        definition = LazyDefinition.new(name, description, subcommand_class_name, path, options)
        define_subcommand(name, Class, definition)
      end

      def lazy_subcommand!(name, description, subcommand_class_name, path, options = {})
        remove_subcommand(name)
        self.lazy_subcommand(name, description, subcommand_class_name, path, options)
        logger.info "subcommand #{name} (#{subcommand_class_name}) was created."
      end

      def find_subcommand(name, fuzzy: true)
        subcommand = super(name)
        if subcommand.nil? && fuzzy
          find_subcommand_starting_with(name)
        else
          subcommand
        end
      end

      def find_subcommand_starting_with(name)
        subcommands = recognised_subcommands.select { |sc| sc.names.any? { |n| n.start_with?(name) } }
        if subcommands.size > 1
          raise HammerCLI::CommandConflict, _('Found more than one command.') + "\n\n" +
                                            _('Did you mean one of these?') + "\n\t" +
                                            subcommands.collect(&:names).flatten.select { |n| n.start_with?(name) }.join("\n\t")
        end
        subcommands.first
      end

      def define_subcommand(name, subcommand_class, definition, &block)
        existing = find_subcommand(name, fuzzy: false)
        if existing
          raise HammerCLI::CommandConflict, _("Can't replace subcommand %<name>s (%<existing_class>s) with %<name>s (%<new_class>s).") % {
            :name => name,
            :existing_class => existing.subcommand_class,
            :new_class => subcommand_class
          }
        end
        subcommand_class = Class.new(subcommand_class, &block) if block
        declare_subcommand_parameters unless has_subcommands?
        recognised_subcommands << definition
      end
    end

  end
end
