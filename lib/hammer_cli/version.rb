module HammerCLI
  def self.version
    @version ||= Gem::Version.new "0.20-develop"
  end
end
