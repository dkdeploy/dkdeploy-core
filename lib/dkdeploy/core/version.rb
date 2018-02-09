module Dkdeploy
  module Core
    # Class for version number
    #
    class Version
      MAJOR = 9
      MINOR = 1
      PATCH = 0

      def self.to_s
        [MAJOR, MINOR, PATCH].join('.')
      end
    end
  end
end
