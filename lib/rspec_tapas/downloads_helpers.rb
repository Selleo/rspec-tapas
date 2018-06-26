module RspecExtensions
  module DownloadsHelpers
    DOWNLOADS_PATH = Rails.root.join('tmp').freeze

    def allow_file_downloads(page)
      bridge = page.driver.browser.send(:bridge)
      path = '/session/:session_id/chromium/send_command'
      path[':session_id'] = bridge.session_id
      bridge.http.call(
        :post,
        path,
        cmd: 'Page.setDownloadBehavior',
        params: { behavior: 'allow', downloadPath: DOWNLOADS_PATH }
      )
    end

    def downloaded_file_contents(name)
      read_attempt = 1

      begin
        File.read(Support::DownloadsHelpers::DOWNLOADS_PATH.join(name))
      rescue Errno::ENOENT => exception
        if read_attempt < 3
          read_attempt += 1
          sleep(Capybara.default_max_wait_time)
          retry
        else
          raise exception
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include RspecExtensions::DownloadsHelpers, type: :feature
end
