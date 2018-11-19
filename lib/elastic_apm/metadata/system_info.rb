# frozen_string_literal: true

module ElasticAPM
  module Metadata
    # @api private
    class SystemInfo
      def initialize(config)
        @config = config
      end

      def build
        {
          hostname: Util.truncate(@config.hostname || `hostname`.chomp),
          architecture: Util.truncate(platform.cpu),
          platform: Util.truncate(platform.os)
        }
      end

      def self.build(config)
        new(config).build
      end

      private

      def platform
        @platform ||= Gem::Platform.local
      end
    end
  end
end
