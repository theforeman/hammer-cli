module HammerCLI
  module Bash
    class PrebuildCompletionCommand < HammerCLI::AbstractCommand
      def execute
        map = HammerCLI::MainCommand.completion_map
        connection = @context[:api_connection].get(
          HammerCLI::Settings.get(:api_connection)
        ) || @context[:api_connection].available
        raise StandardError, 'No connections to the server are available' if connection.nil?

        apidoc_cache = connection.api.apidoc_cache_file
        map['expire'] = {
          'file' => apidoc_cache,
          'sha1sum' => `sha1sum "#{apidoc_cache}"`
        }
        cache_file = HammerCLI::Settings.get(:completion_cache_file)
        cache_dir = File.dirname(cache_file)
        FileUtils.mkdir_p(cache_dir) unless File.directory?(cache_dir)
        File.write(File.expand_path(cache_file), map.to_json)

        HammerCLI::EX_OK
      rescue StandardError => e
        # Raise an error if api_connection is nil or docs are unavailable.
        raise ApipieBindings::DocLoadingError.new('', e)
      end
    end
  end

  HammerCLI::MainCommand.subcommand(
    'prebuild-bash-completion',
    _('Prepare map of options and subcommands for Bash completion'),
    HammerCLI::Bash::PrebuildCompletionCommand
  )
end
