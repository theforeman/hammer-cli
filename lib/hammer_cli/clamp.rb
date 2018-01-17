require 'clamp'

if Clamp.respond_to?(:messages=)
  Clamp.messages = {
    :too_many_arguments =>       _("Too many arguments."),
    :option_required =>          _("Option '%s' is required.") % "%<option>s",
    :option_or_env_required =>   _("Option '%{opt}' (or env %{env}) is required.") % {:opt => "%<option>s", :env => "%<env>s"},
    :option_argument_error =>    _("Option '%{swt}': %{msg}.") % {:swt => "%<switch>s", :msg => "%<message>s"},
    :parameter_argument_error => _("Parameter '%{pmt}': %{msg}.") % {:pmt => "%<param>s", :msg => "%<message>s"},
    :env_argument_error =>       _("%{env}: %{msg}.") % {:env => "%<env>s", :msg => "%<message>s"},
    :unrecognised_option =>      _("Unrecognised option '%s'.") % "%<switch>s",
    :no_such_subcommand =>       _("No such sub-command '%s'.") % "%<name>s",
    :no_value_provided =>        _("No value provided.")
  }
end
