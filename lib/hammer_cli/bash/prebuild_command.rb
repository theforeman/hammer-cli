module HammerCLI
  module Bash
    class PrebuildCompletionCommand < HammerCLI::AbstractCommand
      def execute
        map = HammerCLI::MainCommand.completion_map
        cache_file = File.expand_path(
          HammerCLI::Settings.get(:completion_cache_file)
        )
        cache_dir = File.dirname(cache_file)
        FileUtils.mkdir_p(cache_dir) unless File.directory?(cache_dir)
        File.write(cache_file, map.to_json)

        HammerCLI::EX_OK
      end
    end
  end

  HammerCLI::MainCommand.subcommand(
    'prebuild-bash-completion',
    _('Prepare map of options and subcommands for Bash completion'),
    HammerCLI::Bash::PrebuildCompletionCommand
  )
end
