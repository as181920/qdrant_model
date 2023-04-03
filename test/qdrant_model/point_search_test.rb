require "test_helper"

module QdrantModel
  describe PointSearch do
    before do
      @collection = Collection.new name: "c_name_123"
    end

    it "should search similar points" do
      stub_request(:post, "http://127.0.0.1:6333/collections/#{@collection.name}/points/search")
        .to_return(
          status: 200,
          body: {
            time: 0,
            status: "ok",
            result: [{ id: 789, version: 3, score: 0.9, payload: {}, vector: [1, 2, 3] }]
          }.to_json
        )

      points = PointSearch.create(collection_name: @collection.name, vector: [1, 2, 2], limit: 3)

      refute_empty points
      assert_equal 789, points[0].id
    end
  end
end
