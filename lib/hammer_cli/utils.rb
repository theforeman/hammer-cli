require 'highline'
require 'tempfile'

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

  # Rails implementation: https://github.com/rails/rails/blob/main/actionview/lib/action_view/helpers/text_helper.rb#L260
  def wrap(line_width: 80, break_sequence: "\n")
    split("\n").collect! do |line|
      line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1#{break_sequence}").strip : line
    end * break_sequence
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

  def self.clear_cache
    %i[checksum_cache_file completion_cache_file].each do |f|
      cache_file = File.expand_path(HammerCLI::Settings.get(f))
      File.delete(cache_file) if File.exist?(cache_file)
    end
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

  def self.open_in_editor(content, content_type: '', tempdir: '/tmp', suffix: '.tmp')
    result = content
    Tempfile.open([content_type, suffix], tempdir) do |f|
      f.write(content)
      f.rewind
      system("#{ENV['EDITOR'] || 'vi'} #{f.path}")
      result = f.read
    end
    result
  end

  def self.insert_relative(array, mode, idx, *new_items)
    case mode
    when :prepend
      idx = 0
    when :append
      idx = -1
    when :after
      idx += 1
    when :replace
      array.delete_at(idx)
    end

    array.insert(idx, *new_items)
  end

  def self.expand_invocation_path(path)
    bits = path.split(' ')
    parent_command = HammerCLI::MainCommand
    new_path = (bits[1..-1] || []).each_with_object([]) do |bit, names|
      subcommand = parent_command.find_subcommand(bit)
      next if subcommand.nil?

      names << if subcommand.names.size > 1
                 "<#{subcommand.names.join('|')}>"
               else
                 subcommand.names.first
               end
      parent_command = subcommand.subcommand_class
    end
    new_path.unshift(bits.first).join(' ')
  end
end
