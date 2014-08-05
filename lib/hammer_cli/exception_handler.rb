require 'rest_client'
require 'logging'

module HammerCLI
  class ExceptionHandler

    def initialize(options={})
      @logger = Logging.logger['Exception']
      @output = options[:output]
    end

    def mappings
      [
        [Exception, :handle_general_exception], # catch all
        [Clamp::HelpWanted, :handle_help_wanted],
        [Clamp::UsageError, :handle_usage_exception],
        [RestClient::ResourceNotFound, :handle_not_found],
        [RestClient::Unauthorized, :handle_unauthorized],
        [ApipieBindings::DocLoadingError, :handle_apipie_docloading_error],
      ]
    end

    def handle_exception(e, options={})
      @options = options
      handler = mappings.reverse.find { |m| e.class.respond_to?(:"<=") ? e.class <= m[0] : false }
      return send(handler[1], e) if handler
      raise e
    end

    def output
      @output || HammerCLI::Output::Output.new
    end

    protected

    def print_error(error)
      error = error.join("\n") if error.kind_of? Array
      @logger.error error

      if @options[:heading]
        output.print_error(@options[:heading], error)
      else
        output.print_error(error)
      end
    end

    def print_message(msg)
      output.print_message(msg)
    end

    def log_full_error(e)
      backtrace = e.backtrace || []
      error = "\n\n#{e.class} (#{e.message}):\n    " +
        backtrace.join("\n    ")
        "\n\n"
      @logger.error error
    end

    def handle_general_exception(e)
      print_error _("Error: %s") % e.message
      log_full_error e
      HammerCLI::EX_SOFTWARE
    end

    def handle_usage_exception(e)
      print_error (_("Error: %{message}") + "\n\n" +
                   _("See: '%{path} --help'")) % {:message => e.message, :path => e.command.invocation_path}
      log_full_error e
      HammerCLI::EX_USAGE
    end

    def handle_help_wanted(e)
      print_message e.command.help
      HammerCLI::EX_OK
    end

    def handle_not_found(e)
      print_error e.message
      log_full_error e
      HammerCLI::EX_NOT_FOUND
    end

    def handle_unauthorized(e)
      print_error _("Invalid username or password")
      log_full_error e
      HammerCLI::EX_UNAUTHORIZED
    end

    def handle_apipie_docloading_error(e)
      rake_command = "rake apipie:cache"
      print_error _("Could not load the API description from the server") + "\n  - " +
                  _("is the server down?") + "\n  - " +
                  _("was '%s' run on the server when using apipie cache? (typical production settings)") % rake_command
      log_full_error e
      HammerCLI::EX_CONFIG
    end

  end
end



