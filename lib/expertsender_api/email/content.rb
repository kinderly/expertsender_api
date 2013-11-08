module ExpertSenderApi::Email
  class Content
    require 'expertsender_api/concerns/serializeable'

    attr_accessor :from_name, :from_email, :reply_to_name, :reply_to_email,
                  :subject, :html, :plain

    def insert_to(xml)
      xml.Content {
        attributes.each do |attr|
          xml.send(attr[:name], attr[:value]) unless attr[:value].nil?
        end
      }
    end
  end
end



