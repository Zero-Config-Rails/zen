# frozen_string_literal: true

require_relative "lib/zen/version"

Gem::Specification.new do |spec|
  spec.name = "zen"
  spec.version = Zen::VERSION
  spec.authors = ["Prabin Poudel"]
  spec.email = ["probnpoudel@gmail.com"]

  spec.summary = "CLI for https://zeroconfigrails.com"
  spec.description =
    "CLI for Zero Config Rails. Run the command and relax (zen mode)."
  spec.homepage = "https://zeroconfigrails.com"
  spec.license = nil
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata[
    "allowed_push_host"
  ] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files =
    IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
      ls
        .readlines("\x0", chomp: true)
        .reject do |f|
          (f == gemspec) ||
            f.start_with?(
              *%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile]
            )
        end
    end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 1.3"
  spec.add_dependency "tty-prompt", "~> 0.23"
  spec.add_dependency "tty-spinner", "~> 0.9"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
