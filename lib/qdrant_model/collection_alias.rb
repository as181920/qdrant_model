module QdrantModel
  class CollectionAlias < ApiClient
    include ActiveModel::API

    attr_accessor :collection_name, :alias_name

    class << self
      def list
        get("/aliases")
          .dig("result", "aliases")
          .map { |attrs| new(attrs) }
      end
      alias_method :all, :list

      def create(collection_name:, alias_name:)
        post(
          "/collections/aliases",
          { actions: { create_alias: { collection_name:, alias_name: } } }.to_json
        ).then do |resp_info|
          resp_info["status"] == "ok" ? new(collection_name:, alias_name:) : new(collection_name:, alias_name: nil)
        end
      end

      def update(old_alias_name:, new_alias_name:)
        post(
          "/collections/aliases",
          { actions: { rename_alias: { old_alias_name:, new_alias_name: } } }.to_json
        ).then do |resp_info|
          resp_info["status"] == "ok" ? new(collection_name: nil, alias_name: new_alias_name) : new(collection_name: nil, alias_name: old_alias_name)
        end
      end

      def destroy(alias_name)
        post(
          "/collections/aliases",
          { actions: { delete_alias: { alias_name: } } }.to_json
        ).then do |resp_info|
          resp_info["status"] == "ok" ? new(collection_name: nil, alias_name: nil) : new(collection_name: nil, alias_name:)
        end
      end
    end

    def update(new_alias_name:)
      post(
        "/collections/aliases",
        { actions: { rename_alias: { old_alias_name: alias_name, new_alias_name: } } }.to_json
      ).then { |resp_info| resp_info["status"] == "ok" }
        .tap { |result| result ? self.alias_name = new_alias_name : nil }
    end

    def destroy
      post(
        "/collections/aliases",
        { actions: { delete_alias: { alias_name: } } }.to_json
      ).then do |resp_info|
        self.alias_name = nil if resp_info["status"] == "ok"
        self
      end
    end
  end
end
