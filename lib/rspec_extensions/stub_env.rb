module RspecExRspecExtensionstensions
  module StubEnv
    def stub_env(name, value)
      allow(ENV).to receive(:fetch).and_wrap_original do |m, *args|
        if args.first == name
          value
        else
          m.call(*args)
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include RspecExtensions::StubEnv
end
