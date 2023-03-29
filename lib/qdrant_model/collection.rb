module QdrantModel
  class Collection < ApiClient
    include ActiveModel::API
    include ActiveModel::Validations

    attr_accessor :name

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
    end
  end
end
