
module HammerCLI

  module Subcommand

    class Definition < Clamp::Subcommand::Definition

      def initialize(names, description, subcommand_class, options = {})
        @names = Array(names)
        @description = description
        @subcommand_class = subcommand_class
        @hidden = options[:hidden]
        @warning = options[:warning]
      end

      def hidden?
        @hidden
      end

      def subcommand_class
        warn(@warning) if @warning
        @subcommand_class
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
        warn(@warning) if @warning
        if !@loaded
          require @path
          @loaded = true
          @constantized_class = @subcommand_class.constantize
        end
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

      def define_subcommand(name, subcommand_class, definition, &block)
        existing = find_subcommand(name)
        if existing
          raise HammerCLI::CommandConflict, _("can't replace subcommand %<name>s (%<existing_class>s) with %<name>s (%<new_class>s)") % {
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
