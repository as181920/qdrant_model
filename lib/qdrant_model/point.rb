module QdrantModel
  class Point < ApiClient
    include ActiveModel::API
    include ActiveModel::Validations

    attr_accessor :id, :vector, :payload, :collection_name

    validates :id, presence: true

    class << self
      def where(collection_name:, ids: [], filter: {}, with_vector: true, with_payload: true, page: 1, per: 10) # rubocop:disable Metrics/ParameterLists
        if ids.present?
          find_by_ids(collection_name, ids, with_vector:, with_payload:)
        else
          scroll_by_filter(collection_name:, filter:, with_vector:, with_payload:, page:, per:)
        end
      end

      def upsert(collection_name, params = {})
        put("/collections/#{collection_name}/points", params.to_json)
          .then do |resp_info|
            break [] unless resp_info["status"] == "ok"

            if params[:points].present?
              params[:points].map { |e| new(id: e[:id], vector: e[:vector], payload: e[:payload]) }
            elsif params[:batch].present?
              params.dig(:batch, :vectors).presence
                &.map&.with_index { |e, idx| new(id: params.dig(:batch, :ids, idx), vector: e, payload: params.dig(:batch, :payloads, idx)) }
            end
          end
      end

      def find_by(collection_name:, id:)
        get("/collections/#{collection_name}/points/#{id}")
          .then do |resp_info|
            break {} unless resp_info["status"] == "ok"

            new(resp_info["result"])
          end
      end

      def destroy(collection_name:, ids: [])
        post("/collections/#{collection_name}/points/delete", { points: ids }.to_json)
          .then do |resp_info|
            break {} unless resp_info["status"] == "ok"

            ids.map { |id| new(id:, collection_name:) }
          end
      end

      def find_by_ids(collection_name, ids, with_vector: true, with_payload: true)
        post("/collections/#{collection_name}/points", { ids:, with_vector:, with_payload: }.to_json)
          .then do |resp_info|
            break [] unless resp_info["status"] == "ok"

            resp_info["result"].map { |attrs| new(attrs) }
          end
      end

      def scroll_by_filter(collection_name:, filter:, with_vector:, with_payload:, page: 1, per: 10) # rubocop:disable Metrics/ParameterLists
        limit = per
        offset = page.pred * limit
        post("/collections/#{collection_name}/points/scroll", { limit:, offset:, filter:, with_vector:, with_payload: }.to_json)
          .then do |resp_info|
            break [] unless resp_info["status"] == "ok"

            points = resp_info.dig("result", "points").map { |attrs| new(attrs) }
            PointPage.new(page:, per:, points:, next_page_offset: resp_info.dig("result", "next_page_offset"))
          end
      end
    end

    def upsert(vector:, payload: {})
      put("/collections/#{collection_name}/points", { points: [{ id:, vector:, payload: }] }.to_json)
        .then { |resp_info| resp_info["status"] == "ok" }
    end

    def destroy
      post("/collections/#{collection_name}/points/delete", { points: [id] }.to_json)
        .then do |resp_info|
          resp_info["status"] == "ok" ? self : nil
        end
    end
  end
end
