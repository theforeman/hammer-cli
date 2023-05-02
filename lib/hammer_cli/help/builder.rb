require 'unicode'
module HammerCLI
  module Help
    class Builder < Clamp::Help::Builder
      DEFAULT_LABEL_INDENT = 29

      attr_reader :richtext

      def initialize(richtext = false)
        super()
        @richtext = richtext
      end

      def add_usage(invocation_path, usage_descriptions)
        heading(Clamp.message(:usage_heading))
        usage_descriptions.each do |usage|
          line "    #{HammerCLI.expand_invocation_path(invocation_path)} #{usage}".rstrip
        end
      end

      def add_list(heading, items)
        items.sort! do |a, b|
          a.help[0] <=> b.help[0]
        end
        items.reject! {|item| item.respond_to?(:hidden?) && item.hidden?}

        line
        heading(heading)

        label_width = DEFAULT_LABEL_INDENT
        items.each do |item|
          label = if !HammerCLI.context[:full_help] && item.respond_to?(:family) && item.family && !item.child?
                    item.family.help.first
                  else
                    item.help.first
                  end
          label_width = label.size if label.size > label_width
        end

        items.each do |item|
          if item.respond_to?(:child?) && item.child?
            next unless HammerCLI.context[:full_help]
          end
          label, description = if !HammerCLI.context[:full_help] && item.respond_to?(:family) && item.family
                                 item.family.help
                               else
                                 item.help
                               end
          description.gsub(/^(.)/) { Unicode.capitalize(Regexp.last_match(1)) }.wrap.each_line do |line|
            line " %-#{label_width}s %s" % [label, line]
            label = ''
          end
        end
      end

      def add_text(content)
        line
        line content
      end

      protected

      def heading(label)
        label = "#{label}:"
        label = HighLine.color(label, :bold) if @richtext
        line label
      end
    end
  end
end
