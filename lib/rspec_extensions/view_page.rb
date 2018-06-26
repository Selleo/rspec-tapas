module RspecExtensions
  module ViewPage
    def page
      Capybara.string(rendered)
    end
  end
end

RSpec.configure do |config|
  config.include RspecExtensions::ViewPage, type: :view
  config.around(:each, type: :view) do |example|
    without_partial_double_verification { example.run }
  end
end
