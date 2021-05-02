# frozen_string_literal: true

module HammerCLI
  module Options
    class OptionFamily
      attr_reader :children

      IDS_REGEX = /(\A[Ii][Dd][s]?)|\s([Ii][Dd][s]?)\W|([Ii][Dd][s]?\Z)/

      def initialize(options = {})
        @all = []
        @children = []
        @options = options
        @creator = options[:creator] || Class.new(HammerCLI::Apipie::Command)
        @prefix = options[:prefix]
        @root = options[:root] || options[:aliased_resource] || options[:referenced_resource]
      end

      def description
        types = all.map(&:type).map { |s| s.split('_').last.to_s }
                   .map(&:downcase).join('/')
        parent_desc = @parent.help[1].gsub(IDS_REGEX) { |w| w.gsub(/\w+/, types) }
        desc = parent_desc.strip.empty? ? @options[:description] : parent_desc
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

      def formats
        return [@options[:format].class] if @options[:format]

        all.map(&:value_formatter).map(&:class).uniq
      end

      def switch
        return if @parent.nil? && @children.empty?
        return @parent.help_lhs.strip if @children.empty?

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
        @children << child
        child
      end

      def adopt(child)
        raise ArgumentError, 'Parent cannot be a child within the same family' if child == @parent
        raise ArgumentError, 'Child is already in the family' if @children.include?(child)

        child.family = self
        @children << child
      end

      private

      def format_deprecation_msg(option_desc, deprecation_msg)
        "#{option_desc} (#{deprecation_msg})"
      end

      def new_member(switches, type, description, opts = {}, &block)
        opts = opts.merge(@options)
        opts[:family] = self
        if opts[:deprecated]
          handles = [switches].flatten
          opts[:deprecated] = opts[:deprecated].select do |switch, _msg|
            handles.include?(switch)
          end
        end
        @creator.instance_eval do
          option(switches, type, description, opts, &block)
        end
      end

      def main_switch
        root = @root || @parent.aliased_resource || @parent.referenced_resource || common_root
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
