module QdrantModel
  class Collection < ApiClient
    include ActiveModel::API
    include ActiveModel::Validations

    attr_accessor :name, :properties

    validates :name, presence: true

    class << self
      def list
        get("/collections")
          .dig("result", "collections")
          .map(&method(:new))
      end
      alias_method :all, :list

      def create(params = {})
        name = params.delete(:name)
        put("/collections/#{name}", params.to_json)
          .then { |resp_info| resp_info["status"] == "ok" ? new(name:) : new(name: nil) }
      end

      def find(name)
        get("/collections/#{name}")
          .then { |resp_info| resp_info["result"] }
          .then { |properties| new(name:, properties:) }
      end

      def update(name, optimizers_config: {}, params: {})
        new(name:).update(optimizers_config:, params:)
      end

      def destroy(name)
        new(name:).destroy
      end
    end

    def update(optimizers_config: {}, params: {})
      patch("/collections/#{name}", { optimizers_config:, params: }.to_json)
        .then { |resp_info| resp_info["status"] == "ok" }
    end

    def destroy
      delete("/collections/#{name}")
        .then { |resp_info| resp_info["status"] == "ok" }
    end
  end
end
