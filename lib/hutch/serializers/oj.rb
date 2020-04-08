require 'oj'
require 'active_support/core_ext/hash/indifferent_access'

module Hutch
  module Serializers
    class Oj

      def self.encode(payload)
        ::Oj.dump(payload, mode: :custom)
      end

      def self.decode(payload)
        ::Oj.load(payload, mode: :custom)
      end

      def self.decode(payload, object_class)
        ::Oj.load(payload, mode: :custom, object_class: object_class)
      end

      def self.binary? ; false ; end

      def self.content_type ; 'application/json' ; end

    end
  end
end
