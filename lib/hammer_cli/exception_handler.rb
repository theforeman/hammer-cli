require 'rest_client'
require 'logging'

module HammerCLI
  class ExceptionHandler

    def initialize(options={})
      @output = options[:output] or raise "Missing option output"
      @logger = Logging.logger['Exception']
    end

    def mappings
      [
        [Exception, :handle_general_exception], # catch all
        [RestClient::ResourceNotFound, :handle_not_found],
        [RestClient::Unauthorized, :handle_unauthorized],
      ]
    end

    def handle_exception(e, options={})
      @options = options
      handler = mappings.reverse.find { |m| e.class.respond_to?(:"<=") ? e.class <= m[0] : false }
      return send(handler[1], e) if handler
      raise e
    end

    protected

    def print_error(error)
      error = error.join("\n") if error.kind_of? Array
      @logger.error error

      if @options[:heading]
        @output.print_error @options[:heading], error
      else
        @output.print_error error
      end
    end

    def log_full_error(e)
      backtrace = e.backtrace || []
      @logger.error "\n\n#{e.class} (#{e.message}):\n    " +
        backtrace.join("\n    ")
        "\n\n"
    end

    def handle_general_exception(e)
      print_error "Error: " + e.message
      log_full_error e
      HammerCLI::EX_SOFTWARE
    end

    def handle_not_found(e)
      print_error e.message
      log_full_error e
      HammerCLI::EX_NOT_FOUND
    end

    def handle_unauthorized(e)
      print_error "Invalid username or password"
      log_full_error e
      HammerCLI::EX_UNAUTHORIZED
    end

  end
end



