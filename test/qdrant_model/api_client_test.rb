require "test_helper"

module QdrantModel
  describe ApiClient do
    it "make api request and parse response body" do
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

      resp_info = ApiClient.get "/collections"

      assert_equal "ok", resp_info["status"]
      refute_empty resp_info.dig("result", "collections")
      assert_equal "name_1", resp_info.dig("result", "collections", 0, "name")
    end

    it "make api request and raise error on fail" do
      stub_request(:get, "http://127.0.0.1:6333/collections").to_return(
        status: 400,
        body: {
          time: 0,
          status: { error: "err_msg" },
          result: {}
        }.to_json
      )

      exception = assert_raises ApiClient::ApiResponseError do
        ApiClient.get "/collections"
      end

      assert_equal "err_msg", exception.message
    end
  end
end
