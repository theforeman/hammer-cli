
class String

  # string formatting for ruby 1.8
  def format(params)
    if params.is_a? Hash
      array_params = self.scan(/%[<{]([^>}]*)[>}]/).collect do |name|
        name = name[0]
        params[name.to_s] || params[name.to_sym]
      end

      self.gsub(/%[<{]([^>}]*)[>}]/, '%') % array_params
    else
      self % params
    end
  end

  def camelize()
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end

  def indent_with(indent_str)
    gsub(/^/, indent_str)
  end

end

module HammerCLI

  def self.interactive?
    return false unless STDOUT.tty?
    return HammerCLI::Settings.get(:_params, :interactive) unless HammerCLI::Settings.get(:_params, :interactive).nil?
    HammerCLI::Settings.get(:ui, :interactive) != false
  end

end
