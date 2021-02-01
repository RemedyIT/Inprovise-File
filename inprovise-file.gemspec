require File.join(File.dirname(__FILE__), 'lib/inprovise/file/version')

Gem::Specification.new do |gem|
  gem.authors       = ["Martin Corino"]
  gem.email         = ["mcorino@remedy.nl"]
  gem.description   = %q{File dependency extension for Inprovise scripts}
  gem.summary       = %q{Simple, easy and intuitive provisioning}
  gem.homepage      = "https://github.com/RemedyIT/Inprovise-File"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "inprovise-file"
  gem.require_paths = ["lib"]
  gem.version       = Inprovise::FileAction::VERSION
  gem.add_dependency('inprovise', '~> 0.2')
  gem.post_install_message = ''
end
