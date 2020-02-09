module HammerCLI
  def self.version
    @version ||= Gem::Version.new "2.0-develop"
  end
end
