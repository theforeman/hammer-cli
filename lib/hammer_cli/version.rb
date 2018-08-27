module HammerCLI
  def self.version
    @version ||= Gem::Version.new '0.15-develop'
  end
end
