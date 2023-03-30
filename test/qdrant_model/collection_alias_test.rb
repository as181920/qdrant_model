require "test_helper"

module QdrantModel
  describe CollectionAlias do
    before do
      @collection = Collection.new name: "old_name"

      stub_request(:post, "http://127.0.0.1:6333/collections/aliases").to_return(
        status: 200,
        body: { time: 0, status: "ok", result: true }.to_json
      )
    end

    it "should list all collections aliases" do
      stub_request(:get, "http://127.0.0.1:6333/aliases").to_return(
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

      collection_aliases = CollectionAlias.all

      refute_empty collection_aliases
      assert_equal "c_name", collection_aliases.first.collection_name
      assert_equal "a_name", collection_aliases.first.alias_name
    end

    it "should create alias name for collection" do
      collection_alias = CollectionAlias.create collection_name: @collection.name, alias_name: "alias_name"

      assert_equal "alias_name", collection_alias.alias_name
    end

    it "should update alias name" do
      collection_alias = CollectionAlias.new(collection_name: "c_name", alias_name: "a_name")

      assert_equal "a_name_2", CollectionAlias.update(old_alias_name: "a_name", new_alias_name: "a_name_2").alias_name
      assert collection_alias.update(new_alias_name: "a_name_3")
      assert_equal "a_name_3", collection_alias.alias_name
    end

    it "should destroy alias name" do
      collection_alias = CollectionAlias.new(collection_name: "c_name", alias_name: "a_name")

      assert_nil CollectionAlias.destroy(alias_name: collection_alias.alias_name).alias_name
      assert collection_alias.destroy
      assert_nil collection_alias.alias_name
    end
  end
end
