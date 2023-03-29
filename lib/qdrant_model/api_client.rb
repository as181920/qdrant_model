module QdrantModel
  class ApiClient
    InvalidApiKeyError = Class.new StandardError
    InvalidRequestError = Class.new StandardError
    ApiResponseError = Class.new StandardError

    class << self
      %w[GET POST PUT PATCH DELETE].each do |http_method|
        define_method http_method.underscore do |*args, **kws, &block|
          call_api(http_method, *args, **kws, &block)
        end
      end

      private

        def connection(extra_headers: {})
          Faraday.new(
            url: QdrantModel.configuration.base_url,
            proxy: ENV.fetch("http_proxy", nil).presence,
            headers: {
              "Content-Type": "application/json",
              api_key: QdrantModel.configuration.api_key
            }.merge(extra_headers).compact
          )
        end

        def call_api(http_method, fullpath, payload = nil, extra_headers: {}, &block)
          QdrantModel.logger.info "#{name} #{http_method} #{fullpath} reqt: #{payload&.then { |e| e.size > 4096 ? "[FILTERED]" : e }}"
          resp = connection(extra_headers:).public_send(http_method.underscore, fullpath, payload, &block)
          QdrantModel.logger.info "#{name} #{http_method} #{fullpath} resp(#{resp.status}): #{squish_response(resp)}"

          parse_response(resp)
        end

        def squish_response(resp)
          resp.body.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace, replace: "").squish.truncate(2048)
        end

        def parse_response(resp)
          JSON.parse(resp.body).tap do |resp_info|
            # if resp_info["error"].present?
            raise ApiClient::ApiResponseError, resp_info.dig("status", "error") unless resp.success?
          end
        end
    end
  end
end
