require 'uri'
require 'net/http'
require 'openssl'
require 'json'

module HammerCLI
  module TaskHelper
    module I18n
      class TxApiClient
        class GeneralError < StandardError
          def initialize(error)
            msg = case error
            when Hash
              "#{error['title']}: #{error['detail']}"
            when Array
              error.join("\n")
            else
              error.to_s
            end
            super(msg)
          end
        end

        TX_CONFIG_RC_FILE = '~/.transifexrc'
        TX_BASE_API_URL = 'https://rest.api.transifex.com'

        def initialize(domain:)
          @domain = domain
        end

        def language_stats_collection
          make_call(
            path: '/resource_language_stats',
            params: {
              'filter[project]' => 'o:foreman:p:foreman',
              'filter[resource]' => "o:foreman:p:foreman:r:#{@domain.domain_name}"
            }
          )
        end

        private

        def make_call(path:, params: {}, http_method: :GET, content_type: 'application/vnd.api+json', body: nil)
          url = URI(TX_BASE_API_URL + path)
          url.query = URI.encode_www_form(params)

          body = Net::HTTP.start(url.host, url.port, use_ssl: true) do |https|
            request = Object.const_get("Net::HTTP::#{http_method.to_s.capitalize}").new(url)
            request["accept"] = 'application/vnd.api+json'
            request["content-type"] = content_type
            request["authorization"] = "Bearer #{api_token}"
            request.body = body

            response = https.request(request).read_body
            JSON.parse(response) rescue { 'errors' => ['Could not parse response']}
          end
          return body unless body['errors']

          raise GeneralError.new(body['errors']&.first)
        end

        def api_token
          return ENV['TX_TOKEN'] if ENV['TX_TOKEN']

          token = nil
          config_file = File.expand_path(TX_CONFIG_RC_FILE)
          if File.exist?(config_file)
            File.open(config_file) do |file|
              file.find do |line|
                match = line.match(/^(?<type>token|password)\s*=\s*(?<token>\S+)$/)
                next unless match

                token = match[:token]
              end
            end
          end
          raise GeneralError.new("Could not find API token. Set it in #{config_file} or TX_TOKEN.") unless token

          token
        end
      end
    end
  end
end
