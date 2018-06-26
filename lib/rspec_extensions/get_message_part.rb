module RspecExtensions
  module GetMessagePart
    def get_message_part(mail, content_type)
      is_multipart = mail.body.parts.present?
      if is_multipart
        mail.body.parts.detect { |part| part.content_type.match(content_type) }.body.raw_source
      else
        mail.body.raw_source
      end
    end

    def html_part(mail)
      get_message_part(mail, /html/)
    end

    def text_part(mail)
      get_message_part(mail, /plain/)
    end
  end
end

RSpec.configure do |config|
  config.include RspecExtensions::GetMessagePart, type: :mailer
end
