require 'amazing_print'

module HammerCLI
  module Logger
    module Watch
      def watch(label, obj, options={})
        if debug?
          options = { :plain => HammerCLI::Settings.get(:watch_plain), :indent => -2 }.merge(options)
          debug label + "\n" + obj.ai(options)
        end
      end
    end
  end
end
