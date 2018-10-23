require 'highline'

class String
  def format(params)
    if params.is_a? Hash
      array_params = self.scan(/%[<{]([^>}]*)[>}]/).collect do |name|
        name = name[0]
        params[name.to_s] || params[name.to_sym]
      end
      self.gsub(/%[<]([^>]*)[>]/, '%')
          .gsub(/%[{]([^}]*)[}]/, '%s')
          .gsub(/\%(\W?[^bBdiouxXeEfgGaAcps])/, '%%\1') % array_params
    else
      self.gsub(/\%(\W?[^bBdiouxXeEfgGaAcps])/, '%%\1') % params
    end
  end

  def camelize()
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end

  def indent_with(indent_str)
    gsub(/^/, indent_str)
  end

  def underscore
    word = self.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end

  def constantize
    raise NameError, "Can't constantize empty string" if self.empty?
    HammerCLI.constant_path(self)[-1]
  end

end

class Hash
  # for ruby < 2.5.0
  def transform_keys
    result = {}
    each do |key, value|
      new_key = yield key
      result[new_key] = value
    end
    result
  end
end

module HammerCLI

  def self.tty?
    STDOUT.tty?
  end

  def self.interactive?
    return HammerCLI::Settings.get(:_params, :interactive) unless HammerCLI::Settings.get(:_params, :interactive).nil?
    HammerCLI::Settings.get(:ui, :interactive) != false
  end

  def self.constant_path(name)
    path = name.to_s.split('::').inject([Object]) do |mod, class_name|
      mod << mod[-1].const_get(class_name)
    end
    path.shift
    path
  end

  def self.capitalization
    supported = %w[downcase capitalize upcase]
    capitalization = HammerCLI::Settings.get(:ui, :capitalization).to_s
    return nil if capitalization.empty?
    return capitalization if supported.include?(capitalization)
    warn _("Cannot use such capitalization. Try one of %s.") % supported.join(', ')
    nil
  end

  def self.interactive_output
    @interactive_output ||= HighLine.new($stdin, IO.new(IO.sysopen('/dev/tty', 'w'), 'w'))
  end
end
