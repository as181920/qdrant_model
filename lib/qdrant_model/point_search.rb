module QdrantModel
  class PointSearch < ApiClient
    include ActiveModel::API
    include ActiveModel::Validations

    attr_accessor :vector, :limit, :collection_name, :score_threshold

    validates :vector, presence: true

    class << self
      def create(params = {})
        collection_name = params.delete(:collection_name)
        post("/collections/#{collection_name}/points/search", params.to_json)
          .then do |resp_info|
            break [] unless resp_info["status"] == "ok"

            points = Array(resp_info["result"]).map { |e| Point.new(e.merge(collection_name:)) }
            per = params[:limit] || 5
            PointPage.new(page: (params[:offset].to_i / per).succ, per:, points:, next_page_offset: params[:offset])
          end
      end
    end
  end
end
