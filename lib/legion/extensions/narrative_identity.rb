# frozen_string_literal: true

require 'legion/extensions/narrative_identity/version'
require 'legion/extensions/narrative_identity/helpers/constants'
require 'legion/extensions/narrative_identity/helpers/episode'
require 'legion/extensions/narrative_identity/helpers/theme'
require 'legion/extensions/narrative_identity/helpers/chapter'
require 'legion/extensions/narrative_identity/helpers/narrative_engine'
require 'legion/extensions/narrative_identity/runners/narrative_identity'
require 'legion/extensions/narrative_identity/client'

module Legion
  module Extensions
    module NarrativeIdentity
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
