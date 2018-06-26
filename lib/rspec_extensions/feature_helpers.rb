module RspecExtensions
  module FeatureHelpers
    def display_logs
      puts page.driver.browser.manage.logs.get('browser')
    end

    def ss
      page.save_and_open_screenshot
    end

    def reload_page
      page.evaluate_script('window.location.reload()')
    end
  end
end

RSpec.configure do |config|
  config.include RspecExtensions::FeatureHelpers, type: :feature
end
