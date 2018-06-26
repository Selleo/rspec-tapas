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
