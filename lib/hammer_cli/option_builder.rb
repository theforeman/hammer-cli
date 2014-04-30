
module HammerCLI

  class AbstractOptionBuilder

    def build(builder_params={})
    end

    protected

    def option(*args)
      HammerCLI::Options::OptionDefinition.new(*args)
    end

    def optionamize(name_candidate)
      name_candidate.gsub('_', '-')
    end

  end


  class OptionBuilderContainer < AbstractOptionBuilder

    def build(builder_params={})
      options = []
      builders.each do |b|
        options += b.build(builder_params)
      end
      options
    end

    def builders
      @builders ||= []
      @builders
    end

    def builders=(builders)
      @builders=builders
    end

  end

end
