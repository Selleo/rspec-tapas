module RspecExtensions
  module BehaviorDSL
    BehaviorNotification = Struct.new(:message)
    class BehaviorNotification
      def execution_result
        RSpec::Core::Example::ExecutionResult.new
      end

      def description
        message
      end
    end

    def behavior(name, using: nil)
      if using.present?
        @controller_actions_called = []
        callback = lambda do |*args|
          options = args.extract_options!
          @controller_actions_called << "#{options[:controller]}##{options[:action]}"
        end
        ActiveSupport::Notifications.subscribed(callback, 'start_processing.action_controller') do
          yield
        end

        expect(@controller_actions_called).to(
          include(using),
          "expected #{using} to be used for #{name}, but it was not"
        )
      else
        yield
      end

      reporter.example_passed(BehaviorNotification.new(name))
    end

    def reporter
      RSpec.current_example.reporter
    end
  end
end

RSpec.configure do |config|
  config.include RspecExtensions::BehaviorDSL, type: :feature
end
