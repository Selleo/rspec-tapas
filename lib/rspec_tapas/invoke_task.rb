# https://robots.thoughtbot.com/test-rake-tasks-like-a-boss
module RspecExtensions
  module InvokeTask
    def invoke_task(name, options = {})
      task_path =
        RSpec.current_example.metadata[:file_path].match(%r{spec/(?<file_path>.*)_spec\.rb})[:file_path]
      loaded_files_excluding_current_rake_file =
        $".reject { |file| file == Rails.root.join("#{task_path}.rake").to_s }
      Rake.application = Rake::Application.new
      Rake.application.rake_require(
        task_path,
        [Rails.root.to_s],
        loaded_files_excluding_current_rake_file
      )
      Rake::Task.define_task(:environment)
      task = Rake.application[name]
      task.execute(options)
    end
  end
end

RSpec.configure do |config|
  config.include RspecExtensions::InvokeTask, type: :rake
end
