# frozen_string_literal: true

require_relative "lib/qdrant_model/version"

Gem::Specification.new do |spec|
  spec.name = "qdrant_model"
  spec.version = QdrantModel::VERSION
  spec.authors = ["Andersen Fan"]
  spec.email = ["as181920@gmail.com"]

  spec.summary = "Qdrant restfule api to ruby object relational mapper."
  spec.description = "QdrantModel is a ORM that maps REST resources to Ruby objects"
  spec.homepage = "https://github.com/as181920/qdrant_model"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.2"

  spec.metadata["allowed_push_host"] = ""

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/as181920/qdrant_model"
  spec.metadata["changelog_uri"] = "https://github.com/as181920/qdrant_model/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel"
  spec.add_dependency "activesupport"
  spec.add_dependency "faraday", "~> 2.7"
end
