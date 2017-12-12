require 'hammer_cli/defaults'

module HammerCLI

  def self.context
    @context ||= {
      :defaults => HammerCLI.defaults,
      :is_tty? => HammerCLI.tty?,
      :api_connection => HammerCLI::Connection.new(Logging.logger['Connection']),
      :no_headers => HammerCLI::Settings.get(:ui, :no_headers)
    }
  end

end


