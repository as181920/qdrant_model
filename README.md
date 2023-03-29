# QdrantModel

Map Qdrant REST api to Ruby object.

## Installation

Add this line to your application's Gemfile:

```ruby
  gem "qdrant_model", git: "git@github.com:as181920/qdrant_model.git", branch: "main"
```

### Gem install

Or install with:

```bash
  # gem install qdrant_model
  bundle exec rake install
```

## Usage

Install Qdrant [https://qdrant.tech/documentation/install/]

### Quickstart

Configure

```ruby
QdrantModel.configure do |config|
  config.base_url = "http://127.0.0.1:6333"
end
```

Make api request

```ruby
resp_info = QdrantModel::ApiClient.get "/collections"
```

Get collection list

```ruby
collections = QdrantModel::Collection.all
```

Create collection with name

```ruby
collection = QdrantModel::Collection.create name: "name_123", vectors: { size: 1536, distance: "Dot" }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/qdrant_model.

## References

* [Qdrant REST api](https://qdrant.github.io/qdrant/redoc/index.html)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
