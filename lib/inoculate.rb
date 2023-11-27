# frozen_string_literal: true

# Inoculate is a small, thread-safe dependency injection library configured
# entirely with Ruby.
# It provides several life-cycles and provides dependency access through
# private accessors.
#
# @since 0.1.0
module Inoculate
end

require_relative "inoculate/version"
require_relative "inoculate/errors"
require_relative "inoculate/providers"
require_relative "inoculate/manufacturer"
require_relative "inoculate/porter"
require_relative "inoculate/configurer"
require_relative "inoculate/initialization"

require_relative "inoculate/lifecycle"
