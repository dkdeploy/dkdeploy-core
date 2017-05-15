module Dkdeploy
  module Core
    # Class for version number
    #
    class Version
      MAJOR = 8
      MINOR = 0
      PATCH = 1

      def self.to_s
        [MAJOR, MINOR, PATCH].join('.')
      end
    end
  end
end
