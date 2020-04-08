module Hutch
  module MessageRegistration

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def register
        p self
        p self.get_queue
        p "***"
        Hutch.register_message(self.get_queue)
      end

      def set_queue name
        @queue_name = name
      end

      def get_queue
        @queue_name
      end

    end
  end
end
