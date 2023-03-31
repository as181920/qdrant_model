require "test_helper"

module QdrantModel
  describe Point do
    before do
      @collection = Collection.new name: "c_name_123"
    end

    it "should upsert points" do
      stub_request(:put, "http://127.0.0.1:6333/collections/#{@collection.name}/points")
        .to_return(
          status: 200,
          body: {
            time: 0,
            status: "ok",
            result: { operation_id: 0, status: "acknowledged" }
          }.to_json
        )

      points = Point.upsert \
        @collection.name,
        points: [
          { id: 1, vector: { topic: [1.1, 1.2], content: [2.1, 2.2] }, payload: { topic: "the question", content: "the answer" } },
          { id: 2, vector: { topic: [1.1, 1.2], content: [2.1, 2.2] }, payload: { topic: "Q2", content: "A2" } }
        ]

      assert_equal 2, points.size
      assert_equal 2, points[1].id
      refute_empty points[0].vector[:topic]
    end

    it "should upsert point" do
      point = Point.new collection_name: "c_name", id: 123
      stub_request(:put, "http://127.0.0.1:6333/collections/#{point.collection_name}/points")
        .to_return(
          status: 200,
          body: {
            time: 0,
            status: "ok",
            result: { operation_id: 0, status: "acknowledged" }
          }.to_json
        )

      assert point.upsert(vector: [4, 5, 6], payload: { topic: "NEW_TOPIC" })
    end

    it "should find point" do
      id = 123
      stub_request(:get, "http://127.0.0.1:6333/collections/#{@collection.name}/points/#{id}")
        .to_return(
          status: 200,
          body: {
            time: 0,
            status: "ok",
            result: { id: 123, vector: [1, 2], payload: { topic: "abc" } }
          }.to_json
        )

      point = Point.find_by(collection_name: @collection.name, id:)

      assert_equal id, point.id
      assert_equal [1, 2], point.vector
      assert_equal "abc", point.payload["topic"]
    end

    it "should retrieve multiple points by specified ids" do
      ids = [1, 2, 3]
      stub_request(:post, "http://127.0.0.1:6333/collections/#{@collection.name}/points")
        .to_return(
          status: 200,
          body: {
            time: 0,
            status: "ok",
            result: [
              { id: 123, vector: [1, 2], payload: { topic: "abc" } }
            ]
          }.to_json
        )

      points = Point.where(collection_name: @collection.name, ids:)

      refute_empty points
      refute_empty points[0].vector
    end

    it "should paginate over all points which matches given filtering condition" do
      filter = {}
      stub_request(:post, "http://127.0.0.1:6333/collections/#{@collection.name}/points/scroll")
        .to_return(
          status: 200,
          body: {
            time: 0,
            status: "ok",
            result: {
              points: [{ id: 123, vector: [1, 2], payload: { topic: "abc" } }],
              next_page_offset: 0
            }
          }.to_json
        )

      points = Point.where(collection_name: @collection.name, filter:)

      refute_empty points
      refute_empty points[0].vector
    end

    it "should delete points" do
      stub_request(:post, "http://127.0.0.1:6333/collections/#{@collection.name}/points/delete")
        .to_return(
          status: 200,
          body: {
            time: 0,
            status: "ok",
            result: {}
          }.to_json
        )

      destroyed_points = Point.destroy(collection_name: @collection.name, ids: [1, 2, 3])

      refute_empty destroyed_points
      assert_equal 3, destroyed_points.size
    end

    it "should delete point" do
      point = Point.new collection_name: "c_name", id: 123, vector: [1, 2, 3]
      stub_request(:post, "http://127.0.0.1:6333/collections/#{point.collection_name}/points/delete")
        .to_return(
          status: 200,
          body: {
            time: 0,
            status: "ok",
            result: {}
          }.to_json
        )

      assert point.destroy
    end
  end
end
