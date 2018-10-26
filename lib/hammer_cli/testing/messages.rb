module HammerCLI
  module Testing
    module Messages
      def get_subcommands(cmd)
        return [] unless cmd.respond_to? :recognised_subcommands
        cmd.recognised_subcommands.map { |c| c.subcommand_class }
      end

      def all_subcommands(cmd, parent=HammerCLI::AbstractCommand)
        result = []
        get_subcommands(cmd).each do |klass|
          if klass < parent
            result << klass
            result += all_subcommands(klass, parent)
          end
        end
        result
      end

      def assert_msg_period(cmd, method_name)
        if cmd.respond_to?(method_name) && !cmd.send(method_name).nil?
          assert(cmd.send(method_name).end_with?('.'), "#{cmd}.#{method_name} doesn't end with '.'")
        end
      end

      def refute_msg_period(cmd, method_name)
        if cmd.respond_to?(method_name) && !cmd.send(method_name).nil?
          refute(cmd.send(method_name).end_with?('.'), "#{cmd}.#{method_name} ends with '.'")
        end
      end

      def check_option_description(cmd, opt)
        refute opt.description.end_with?('.'), "Description for option #{opt.long_switch} in #{cmd} ends with '.'"
      end

      def check_command_messages(cmd, except: [])
        cmd.recognised_options.each do |opt|
          check_option_description(cmd, opt)
        end
        refute_msg_period(cmd, :desc) unless except.include?(:desc)
        assert_msg_period(cmd, :success_message) unless except.include?(:success_message)
        refute_msg_period(cmd, :failure_message) unless except.include?(:failure_message)
      end

      def check_all_command_messages(main_cmd, parent=HammerCLI::AbstractCommand, except: {})
        all_subcommands(main_cmd, parent).each do |cmd|
          it "test messages of #{cmd}" do
            check_command_messages(cmd, except: (except[cmd.to_s] || []))
          end
        end
      end
    end
  end
end
