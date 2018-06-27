require_relative '../locators/find_table_row.rb'
require 'rspec/expectations'

Capybara::Session.include FindTableRow
Capybara::Node::Simple.include FindTableRow

module RSpecTapas
  module Matchers
    RSpec::Matchers.define :have_table_row do |*expected|
      match do |page|
        with_delay do
          page.find_table_row(*expected)
        end
      end

      match_when_negated do
        page.find_table_row(*expected)
        false
      rescue Capybara::ElementNotFound
        true
      end

      failure_message do
        @failure_message
      end

      private

      def with_delay
        Timeout.timeout(Capybara.default_max_wait_time) do
          yield
        rescue => error
          @failure_message = error.message
          sleep(1)
          retry
        end
      rescue Timeout::Error
        false
      end
    end
  end
end
