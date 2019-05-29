# frozen_string_literal: true

module Dkdeploy
  module Core
    # Class for version number
    #
    class Version
      MAJOR = 9
      MINOR = 2
      PATCH = 3

      def self.to_s
        [MAJOR, MINOR, PATCH].join('.')
      end
    end
  end
end
