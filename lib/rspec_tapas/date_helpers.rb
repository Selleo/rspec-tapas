module RspecExtensions
  module DateHelpers
    def at_date(*parts)
      travel_to(Date.new(*parts)) do
        yield
      end
    end

    def freeze_time
      travel_to(Time.current) do
        yield
      end
    end
  end
end

RSpec.configure do |config|
  config.include RspecExtensions::DateHelpers
end
