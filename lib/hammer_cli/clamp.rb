require 'clamp'

if Clamp.respond_to?(:messages=)
  Clamp.messages = {
    :too_many_arguments =>       _("too many arguments"),
    :option_required =>          _("option '%<option>s' is required"),
    :option_or_env_required =>   _("option '%<option>s' (or env %<env>s) is required"),
    :option_argument_error =>    _("option '%<switch>s': %<message>s"),
    :parameter_argument_error => _("parameter '%<param>s': %<message>s"),
    :env_argument_error =>       _("%<env>s: %<message>s"),
    :unrecognised_option =>      _("Unrecognised option '%<switch>s'"),
    :no_such_subcommand =>       _("No such sub-command '%<name>s'"),
    :no_value_provided =>        _("no value provided")
  }
end
