# frozen_string_literal: true

require "test_helper"

describe QdrantModel do
  it "has a version number" do
    refute_nil QdrantModel::VERSION
  end

  it "define errors" do
    assert_equal StandardError, QdrantModel::Error.superclass
    assert_equal QdrantModel::Error, QdrantModel::ConfigurationError.superclass
  end

  it "defines logger" do
    assert_instance_of Logger, QdrantModel.logger
  end
end
