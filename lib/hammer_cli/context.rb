require 'hammer_cli/defaults'

module HammerCLI

  def self.context
    {
      :defaults => HammerCLI.defaults
    }
  end

end


