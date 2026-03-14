# frozen_string_literal: true

require_relative 'lib/legion/extensions/narrative_identity/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-narrative-identity'
  spec.version       = Legion::Extensions::NarrativeIdentity::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Narrative Identity'
  spec.description   = 'Autobiographical narrative identity for LegionIO — the agent constructs and ' \
                       'maintains a life narrative of who it is, what it has done, and what it values, ' \
                       'based on Dan McAdams narrative identity theory'
  spec.homepage      = 'https://github.com/LegionIO/lex-narrative-identity'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-narrative-identity'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-narrative-identity'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-narrative-identity'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-narrative-identity/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
end
