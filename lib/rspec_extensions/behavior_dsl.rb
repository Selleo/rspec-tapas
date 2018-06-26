module RspecExtensions
  module BehaviorDSL
    def behavior(name)
      metadata[:description_args].push(name)
      refresh_description
      yield
      metadata[:description_args].pop
      refresh_description
    end

    private

    def refresh_description
      metadata[:description] = metadata[:description_args].join(' ')
      metadata[:full_description] = \
      [metadata[:example_group][:full_description]].
        concat(metadata[:description_args]).join(' ')
    end

    def metadata
      RSpec.current_example.metadata
    end
  end
end

RSpec.configure do |config|
  config.include RspecExtensions::BehaviorDSL, type: :feature
end
