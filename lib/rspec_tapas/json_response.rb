module RspecExtensions
  module JsonResponse
    def json_response
      parsed_json = JSON.parse(response.body)
      if parsed_json.is_a?(Hash)
        HashWithIndifferentAccess.new(parsed_json)
      else
        parsed_json.map do |entry|
          entry.is_a?(Hash) ? HashWithIndifferentAccess.new(entry) : entry
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include RspecExtensions::JsonResponse, type: :request
  config.include RspecExtensions::JsonResponse, type: :controller
end
