module HammerCLI

  class CommandConflict < StandardError; end
  class OperationNotSupportedError < StandardError; end
  class ModuleLoadingError < StandardError; end
  class ModuleCircularDependency < StandardError; end
  class ModuleDisabledButRequired < StandardError; end

end
