
class String
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

module HammerCLI

  def self.tty?
    STDOUT.tty?
  end

  def self.interactive?
    return false unless tty?
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

end
