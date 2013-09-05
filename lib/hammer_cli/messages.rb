
module HammerCLI
  module Messages

    def self.included(base)
      base.extend(ClassMethods)
    end

    def success_message_for(action)
      self.class.success_message_for action
    end

    def success_message
      self.class.success_message
    end

    def failure_message_for(action)
      self.class.failure_message_for action
    end

    def failure_message
      self.class.failure_message
    end

    def handle_exception(e)
      exception_handler.handle_exception e, :heading => failure_message
    end

    module ClassMethods
      def success_message_for(action, msg=nil)
        @success_message ||= {}
        @success_message[action] = msg unless msg.nil?
        @success_message[action]
      end

      def success_message(msg=nil)
        success_message_for :default, msg
      end

      def failure_message_for(action, msg=nil)
        @failure_message ||= {}
        @failure_message[action] = msg unless msg.nil?
        @failure_message[action]
      end

      def failure_message(msg=nil)
        failure_message_for :default, msg
      end
    end

  end
end



