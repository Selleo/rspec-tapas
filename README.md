# rspec-tapas

rspec-tapas is a set of small helpers and extensions we often use in [Selleo](https://selleo.com/) when testing our ruby apps.

## Installation

To install rspec-tapas just add following line to your `Gemfile`s `:test` group

```ruby
gem 'ruby-tapas'
```

then just `bundle install` and require it in `rails_helper.rb`

```ruby
require 'rspec_tapas/all'
```

## Tapas

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

To include this helper only, call `require rspec_tapas/stub_env`

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

To include this helper only, call `require rspec_tapas/date_helpers`

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

To include this helper only, call `require rspec_tapas/view_page`

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

To include this helper only, call `require rspec_tapas/invoke_task`

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

To include this helper only, call `require rspec_tapas/get_message_part`

`GetMessagePart` is accessible only in mailer specs
