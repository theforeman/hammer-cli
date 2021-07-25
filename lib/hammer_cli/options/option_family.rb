# frozen_string_literal: true

module HammerCLI
  module Options
    class OptionFamilyRegistry < Array
      # rubocop:disable Style/Alias
      alias_method :register, :push
      alias_method :unregister, :delete
      # rubocop:enable Style/Alias
    end

    class OptionFamily
      attr_reader :children

      IDS_REGEX = /(\A[Ii][Dd][s]?)|\s([Ii][Dd][s]?)\W|([Ii][Dd][s]?\Z)|(numeric identifier|identifier)/.freeze

      def initialize(options = {})
        @all = []
        @children = []
        @options = options
        @creator = options[:creator] || self
        @prefix = options[:prefix]
        @root = options[:root] || options[:aliased_resource] || options[:referenced_resource]
        @creator.family_registry.register(self) if @creator != self
      end

      def description
        types = all.map(&:type).map { |s| s.split('_').last.to_s }
                   .map(&:downcase).join('/')
        parent_desc = @parent.help[1].gsub(IDS_REGEX) { |w| w.gsub(/\b.+\b/, types) }
        desc = @options[:description] || parent_desc.strip.empty? ? @options[:description] : parent_desc
        if @options[:deprecation].class <= String
          format_deprecation_msg(desc, _('Deprecated: %{deprecated_msg}') % { deprecated_msg: @options[:deprecation] })
        elsif @options[:deprecation].class <= Hash
          full_msg = @options[:deprecation].map do |flag, msg|
            _('%{flag} is deprecated: %{deprecated_msg}') % { flag: flag, deprecated_msg: msg }
          end.join(', ')
          format_deprecation_msg(desc, full_msg)
        else
          desc
        end
      end

      def help
        [help_lhs, help_rhs]
      end

      def help_lhs
        return @parent&.help_lhs if @children.empty?

        types = all.map(&:value_formatter).map { |f| f.completion_type[:type].to_s.upcase }
        switch + ' ' + types.uniq.join('/')
      end

      def help_rhs
        description || @parent.help[1]
      end

      def formats
        return [@options[:format].class] if @options[:format]

        all.map(&:value_formatter).map(&:class).uniq
      end

      def switch
        return if @parent.nil? && @children.empty?
        return @parent.switches.join(', ').strip if @children.empty?

        switch_start = main_switch.each_char
                                  .zip(*all.map(&:switches).flatten.map(&:each_char))
                                  .select { |a, b| a == b }.transpose.first.join
        suffixes = all.map do |m|
          m.switches.map { |s| s.gsub(switch_start, '') }
        end.flatten.reject(&:empty?).sort { |x, y| x.size <=> y.size }
        "#{switch_start}[#{suffixes.join('|')}]"
      end

      def head
        @parent
      end

      def all
        @children + [@parent].compact
      end

      def parent(switches, type, description, opts = {}, &block)
        raise StandardError, 'Option family can have only one parent' if @parent

        @parent = new_member(switches, type, description, opts, &block)
      end

      def child(switches, type, description, opts = {}, &block)
        child = new_member(switches, type, description, opts, &block)
        return unless child

        @children << child
        child
      end

      def adopt(child)
        raise ArgumentError, 'Parent cannot be a child within the same family' if child == @parent
        raise ArgumentError, 'Child is already in the family' if @children.include?(child)

        child.family = self
        @children << child
      end

      def root
        @root || @parent&.aliased_resource || @parent&.referenced_resource || common_root
      end

      def option(*args)
        HammerCLI::Apipie::OptionDefinition.new(*args)
      end

      def find_option(switch)
        all.find { |m| m.handles?(switch) }
      end

      private

      def format_deprecation_msg(option_desc, deprecation_msg)
        "#{option_desc} (#{deprecation_msg})"
      end

      def new_member(switches, type, description, opts = {}, &block)
        opts = opts.merge(@options)
        opts[:family] = self
        if opts[:deprecated]
          handles = Array(switches)
          opts[:deprecated] = opts[:deprecated].select do |switch, _msg|
            handles.include?(switch)
          end
        end
        @creator.instance_eval do
          unless Array(switches).any? { |s| find_option(s) }
            option(switches, type, description, opts, &block)
          end
        end
      end

      def main_switch
        "--#{@prefix}#{root}".tr('_', '-')
      end

      def common_root
        switches = all.map(&:switches).flatten
        shortest = switches.min_by(&:length)
        max_len = shortest.length
        max_len.downto(0) do |curr_len|
          0.upto(max_len - curr_len) do |start|
            root = shortest[start, curr_len]
            return root[2..-1].chomp('-') if switches.all? { |switch| switch.include?(root) }
          end
        end
      end
    end
  end
end
