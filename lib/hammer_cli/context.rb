require 'hammer_cli/defaults'

module HammerCLI

  def self.context
    {
      :defaults => HammerCLI.defaults,
      :is_tty? => HammerCLI.tty?
    }
  end

end


