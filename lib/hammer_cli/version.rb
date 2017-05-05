module HammerCLI
  def self.version
    @version ||= Gem::Version.new '0.11-develop'
  end
end
