module HammerCLI
  def self.version
    @version ||= Gem::Version.new '0.12-develop'
  end
end
