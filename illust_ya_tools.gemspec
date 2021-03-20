require_relative 'lib/illust_ya_tools/version'

Gem::Specification.new do |spec|
  spec.name          = "illust_ya_tools"
  spec.version       = IllustYaTools::VERSION
  spec.authors       = ["bannzai"]
  spec.email         = ["kingkonog999yhirose@gmail.com"]

  spec.summary       = %q{illust ya tools}
  spec.description   = %q{illust ya tools}
  spec.homepage      = "https://github.com/bannzai/illust_ya_tools"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bannzai/illust_ya_tools"
  spec.metadata["changelog_uri"] = "https://github.com/bannzai/illust_ya_tools"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'selenium-webdriver'
  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'pry-doc'
end
