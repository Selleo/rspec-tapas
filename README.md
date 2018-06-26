# rspec-tapas

rspec-tapas is a set of small helpers and extensions we often use in [Selleo](https://selleo.com/) when testing our ruby apps.

## Installation

To install rspec-tapas just add following line to your `Gemfile`s `:test` group

```ruby
gem 'ruby-tapas'
```

then just require it in `rails_helper.rb`

```ruby
require 'rspec_tapas/all'
```

## Tapas

### StubEnv

`StubEnv` is an extension that allows you to quickly stub values that should be retrieved from `ENV`.
It is assumed here, that you will use `fetch` method to retrieve such value (so it yields an exception when given ENV is not defined what sounds like a reasonable default).

Example usage

```ruby
it 'sends a notification after checkout' do
    stub_env('CHECKOUT_TIME', '13:00')
    #...
end
```

To include this helper only, call `require rspec_tapas/stub_env`
