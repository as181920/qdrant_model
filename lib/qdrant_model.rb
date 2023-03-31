require "faraday"
require "active_support/all"
require "active_model"
require_relative "qdrant_model/version"
require_relative "qdrant_model/api_client"
require_relative "qdrant_model/collection"
require_relative "qdrant_model/collection_alias"
require_relative "qdrant_model/collection_index"
require_relative "qdrant_model/collection_cluster"
require_relative "qdrant_model/collection_snapshot"
require_relative "qdrant_model/point"
require_relative "qdrant_model/point_page"
# require_relative "qdrant_model/cluster"
# require_relative "qdrant_model/snapshot"
# require_relative "qdrant_model/service"

module QdrantModel
  Error = Class.new StandardError
  ConfigurationError = Class.new Error

  class Configuration
    attr_accessor :base_url, :api_key, :logger

    def initialize(base_url: nil, api_key: nil)
      @base_url = base_url.presence || ENV.fetch("qdrant_base_url", "http://127.0.0.1:6333")
      @api_key = api_key.presence || ENV.fetch("qdrant_api_key", "")
      @logger = defined?(Rails) ? Rails.logger : Logger.new($stdout)
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def base_url
      configuration.base_url
    end

    def logger
      configuration.logger
    end
  end
end
