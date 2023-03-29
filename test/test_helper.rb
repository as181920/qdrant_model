# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "qdrant_model"

require "minitest/autorun"
require "minitest/mock"
require "mocha/minitest"
require "webmock/minitest"

require "minitest/reporters"
Minitest::Reporters.use!

QdrantModel.configuration.logger = Logger.new(nil)
