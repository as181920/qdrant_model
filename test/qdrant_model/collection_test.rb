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

    it "should show collection detailed info by name" do
      stub_request(:get, "http://127.0.0.1:6333/collections/name_123").to_return(
        status: 200,
        body: {
          time: 0,
          status: "ok",
          result: {
            status: "green",
            optimizer_status: "ok",
            vectors_count: 0,
            indexed_vectors_count: 0,
            points_count: 0,
            segments_count: 0,
            config: {
              params: {
                vectors: { size: 1536, distance: "Cosine" },
                shard_number: 1,
                replication_factor: 1,
                write_consistency_factor: 1,
                on_disk_payload: false
              },
              hnsw_config: {},
              optimizer_config: {},
              wal_config: {},
              quantization_config: nil
            },
            payload_schema: {}
          }
        }.to_json
      )

      collection = Collection.find "name_123"

      assert_equal "name_123", collection.name
      assert_equal 1536, collection.properties.dig("config", "params", "vectors", "size")
    end

    it "should update parameters for existing collection" do
      name = "name_456"
      stub_request(:patch, "http://127.0.0.1:6333/collections/#{name}")
        .to_return(
          status: 200,
          body: { time: 0, status: "ok", result: true }.to_json
        )

      assert Collection.new(name:).update(optimizers_config: { deleted_threshold: 0 })
      assert Collection.update(name, params: { replication_factor: 1 })
    end

    it "should drop collection and all associated data" do
      name = "name_789"
      stub_request(:delete, "http://127.0.0.1:6333/collections/#{name}")
        .to_return(
          status: 200,
          body: { time: 0, status: "ok", result: true }.to_json
        )

      assert Collection.new(name:).destroy
      assert Collection.destroy(name)
    end

    it "should list aliases for collection" do
      collection = Collection.new name: "c_name"
      stub_request(:get, "http://127.0.0.1:6333/collections/#{collection.name}/aliases").to_return(
        status: 200,
        body: {
          time: 0,
          status: "ok",
          result: {
            aliases: [
              { collection_name: "c_name", alias_name: "a_name" }
            ]
          }
        }.to_json
      )

      collection_aliases = collection.aliases

      refute_empty collection_aliases
      assert_equal collection.name, collection_aliases.first.collection_name
      assert_equal "a_name", collection_aliases.first.alias_name
    end
  end
end
