module HammerCLI::Output

  class Dsl

    def initialize(options={})
      @current_path = options[:path] || []
    end

    def fields
      @fields ||= []
      @fields
    end

    def build(&block)
      self.instance_eval(&block)
    end

    protected

    def field(key, label, type=nil, options={}, &block)
      options[:path] = current_path.clone
      unless key.nil?
        options[:path] << key
        options[:key] = key
      end
      options[:label] = label
      type ||= Fields::Field
      custom_field type, options, &block
    end

    def custom_field(type, options={}, &block)
      self.fields << type.new(options, &block)
    end

    def label(label, options={}, &block)
      options[:path] = current_path.clone
      options[:label] = label
      custom_field Fields::Label, options, &block
    end

    def from(key)
      self.current_path.push key
      yield if block_given?
      self.current_path.pop
    end

    def collection(key, label, options={}, &block)
      field key, label, Fields::Collection, options, &block
    end


    def current_path
      @current_path ||= []
      @current_path
    end

  end

end
