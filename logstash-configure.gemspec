Gem::Specification.new do |s|

  s.name            = 'logstash-configure'
  s.version         = '1.0.0'
  s.licenses        = ['ThoughtWorks']
  s.summary         = "Treat flowctl logger."
  s.description     = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program"
  s.authors         = ["ThoughtWorks"]
  s.email           = 'info@elastic.co'
  s.homepage        = "http://www.elastic.co/guide/en/logstash/current/index.html"
  s.require_paths = ["lib"]

  # Files
  s.files = `git ls-files`.split($\)

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", '>= 1.4.0', '< 2.0.0'
  s.add_runtime_dependency 'jls-grok', '~> 0.11.1'
  s.add_development_dependency 'logstash-filter-grok', '~> 1.0.0'
  s.add_development_dependency 'logstash-devutils'
end

