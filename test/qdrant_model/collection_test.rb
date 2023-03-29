require "test_helper"

module QdrantModel
  describe Collection do
    it "should list all collection names" do
      stub_request(:get, "http://127.0.0.1:6333/collections").to_return(
        status: 200,
        body: {
          time: 0,
          status: "ok",
          result: {
            collections: [
              { name: "name_1" }
            ]
          }
        }.to_json
      )

      collections = Collection.all

      refute_empty collections
      assert_equal "name_1", collections.first.name
    end

    it "should create collection with name" do
      stub_request(:put, "http://127.0.0.1:6333/collections/name_123").to_return(
        status: 200,
        body: { time: 0, status: "ok", result: true }.to_json
      )

      collection = Collection.create name: "name_123", vectors: { size: 1, distance: "dot" }

      assert_predicate collection, :valid?
      assert_equal "name_123", collection.name
    end
  end
end
