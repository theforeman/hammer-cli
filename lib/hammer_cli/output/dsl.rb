module HammerCLI::Output

  module Dsl

    def output definition=nil
      output_definition.append definition unless definition.nil?
      yield if block_given?
    end

    def field name, label, options={}, &formatter
      options[:formatter] = formatter if block_given?
      options[:path] = current_path.clone
      output_definition.add_field name, label, options
    end

    def abstract_field name, label, options={}, &formatter
      options[:record_formatter] = formatter if block_given?
      options[:path] = current_path.clone
      output_definition.add_field name, label, options
    end

    def from key
      current_path.push key
      yield if block_given?
      current_path.pop
    end

    def current_path
      @current_path ||= []
      @current_path
    end

    def output_definition
      @output_definition ||= HammerCLI::Output::Definition.new
      @output_definition
    end

    def heading h
      @output_heading = h
    end

    def output_heading
      @output_heading
    end

  end

end
