# rspec-tapas

rspec-tapas is a set of small helpers and extensions we often use in [Selleo](https://selleo.com/) when testing our ruby apps.

## Installation

To install rspec-tapas just add following line to your `Gemfile`s `:test` group

```ruby
gem 'rspec-tapas'
```

then just `bundle install` and require it in `rails_helper.rb`

```ruby
require 'rspec_tapas/all'
```

## Helpers

### StubEnv

`StubEnv` is an extension that allows you to quickly stub values that should be retrieved from `ENV`.
It is assumed here, that you will use `fetch` method to retrieve such value (so it yields an exception when given ENV is not defined what sounds like a reasonable default).

*Example*

```ruby
it 'sends a notification after checkout' do
    stub_env('CHECKOUT_TIME', '13:00')
    #...
end
```

To include this extension only, call `require rspec_tapas/stub_env`

`StubEnv` is accessible in all types of specs

### DateHelpers

`DateHelpers` is a set of two methods that facilitate using `ActiveSupport::Testing::TimeHelpers`. Therefore you need to include `ActiveSupport::Testing::TimeHelpers` in your config if you want to use `DateHelpers`. It is as simple as

```ruby
RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
end
```

#### at_date

`at_date` runs contents of the block at given date, provided in a format acceptable by `Date.new`. It is basically a shortcut to `travel_to(Date.new(*args)){}`.

*Example*

```ruby
context 'one day before deadline' do
    it 'sends a reminder' do
        #...
        at_date(2018, 1, 12) do
            SendPendingReminders.call
        end
        #...
    end
end
```

#### freeze_time

`freeze_time` freezes the time and runs contents of the block at. It is basically a shortcut to `travel_to(Time.current){}`.

*Example*

```ruby
it 'discards records created at the same time' do
    #...
    freeze_time do
      user_1 = create(:user)
      user_2 = create(:user)
    end
    #...
end
```

To include this extension only, call `require rspec_tapas/date_helpers`

`DateHelpers` are accessible in all types of specs

### ViewPage

`ViewPage` is a small helper that allows testing views using capybara helpers, usually limited only to feature specs.

*Example*

```ruby
RSpec.describe 'users/show.html.erb', type: :view do
  it 'renders user name' do
    user = create(:user, name: "Tony")
    allow(view).to receive(:user) { user }

    render

    expect(page).to have_content("Tony")
  end
end
```

To include this extension only, call `require rspec_tapas/view_page`

`ViewPage` is accessible only in view specs


### InvokeTask

`InvokeTask` is a small helper that facilitates calling rake tasks when testing them.

*Example*

```ruby
RSpec.describe 'db:materialize', type: :rake do
  it 'materializes db view by name' do
    database = double(:database)
    allow(Scenic).to receive(:database) { database }
    allow(database).to receive(:refresh_materialized_view)

    invoke_task('db:materialize', view_name: 'sample_view')

    expect(database).to \
      have_received(:refresh_materialized_view).with('sample_view')
  end
end
```

To include this extension only, call `require rspec_tapas/invoke_task`

`InvokeTask` is accessible only in rake specs


### GetMessagePart

`GetMessagePart` is a set of helpers to facilitate extraction of html/plain parts of emails sent. To extract plaintext part from email, use `text_part(mail)`. To extract HTML part, use `html_part(mail)`.

```ruby
RSpec.describe ReportMailer, type: :mailer do
  describe '#summary' do
    it 'creates email containing orders summary' do
      create_list(:order, 2)
      mail = ReportMailer.summary

      expect(mail.subject).to eq('Orders summary')
      expect(html_part(mail)).to include_html(
        <<~HTML
            <h1>Orders summary</h1>
            <strong>Total orders created:</strong> 2 <br /> 
        HTML
      )
      expect(text_part(mail)).to include('Total orders created: 2')
    end
  end
end
```

To include this extension only, call `require rspec_tapas/get_message_part`

`GetMessagePart` is accessible only in mailer specs

### JsonResponse

`JsonResponse` is a simple helper that transforms JSON encoded response body to `HashWithIndifferentAccess` or an array of those. This is to facilitate using regular matchers to assert such response.

*Example*

```ruby
it 'returns user names and emails' do
  create(:user, name: 'Tony', email: 'tony@stark.dev')
  create(:user, name: 'Bruce', email: 'bruce@wayne.dev')

  get '/v1/users'

  expect(json_response).to match(
    data: [
      { name: 'Tony', email: 'tony@stark.dev' },
      { name: 'Bruce', email: 'bruce@wayne.dev' },
    ]
  )
end
```

To include this extension only, call `require rspec_tapas/json_response`

`JsonResponse` is accessible only in request and controller specs

### DownloadsHelpers

`DownloadsHelpers` is a set of two helpers oriented on facilitating testing downloads. First, we need to allow downloading file in given feature spec by calling `allow_file_downloads(page)`. Then, to get downloaded file contents, we need to use `downloaded_file_contents(file_name)` helper.

To allow downloads with headless-chrome capybara driver, we need to configure it in specific way. See example below:

```ruby
require 'selenium/webdriver'

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-gpu')
  options.add_argument('--disable-popup-blocking')
  options.add_argument('--window-size=1920,1200')
  options.add_preference(
    :download,
    directory_upgrade: true,
    prompt_for_download: false,
    default_directory: RspecExtensions::DownloadsHelpers::DOWNLOADS_PATH
  )
  options.add_preference(:browser, set_download_behavior: { behavior: 'allow' })

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :headless_chrome
```

Then, testing downloads is just a matter of few lines of code.

*Example*

```ruby
allow_file_downloads(page)

click_on 'Download report'

expect(downloaded_file_contents('daily_report.csv')).to eq("Name, Total revenue\nBatman suits, 1000")
```

To include this extension only, call `require rspec_tapas/downloads_helpers`

`DownloadsHelpers` are accessible only in feature specs

### FeatureHelpers

`FeatureHelpers` module contains a couple of methods useful in features specs.

- `display_logs` will display browser logs in console. This is useful for debugging javascript errors in feature specs.
- `ss` is a shortcut for `page.save_and_open_screenshot`
- `reload_page` is a handy shortcut for reloading current page.

To include this extension only, call `require rspec_tapas/feature_helpers`

`FeatureHelpers` are accessible only in feature specs

### BehaviorDSL

`BehaviorDSL` module has two roles. First one is to add some syntactic sugar to feature specs, by introducing additional level of describing context, but without interrupting test. This way you can group actions and assertions in readable blocks.

Second role of `BehaviorDSL` is to add capability of asserting feature - controller integration. This way we can ensure, that given block of capybara interactions were using particular controller action.

*Example*

```ruby
RSpec.describe 'Users management' do
  scenario do
    behavior 'Admin browses existing users', using: 'Admin::UsersController#index' do
      create(:user, name: 'Luke Cage')
      create(:unit, name: 'Jessica Jones')

      visit '/admin/users'

      expect(page).to have_row_content('Full name' => 'Luke Cage')
      expect(page).to have_row_content('Full name' => 'Jessica Jones')
    end

    behavior 'Admin updates existing user' do
      #...
    end
  end
end
```

To include this extension only, call `require rspec_tapas/behavior_dsl`

`BehaviorDSL` is accessible only in feature specs

## Matchers

### have_table_row

`have_table_row` is a matcher dedicated to finding table rows by their values correlated with specific headers. As so, this is mostly useful in feature specs.

*Examples*

```ruby
# Asserting headers by their names
expect(page).to have_table_row('First name' => 'Tony', 'Last name' => 'Stark', 'Rating' => 4.5)

# Asserting headers by their indices
expect(page).to have_table_row(1 => 'Tony', 2 => 'Stark', 3 => 4.5)

# Asserting headers by their indices - shorter version
expect(page).to have_table_row('Tony', 'Stark', 4.5)

# Composing matchers
expect(page).to have_table_row(have_content('ny'), 'Stark')
```

To include this matcher only, call `require rspec_tapas/matchers/have_table_row`
