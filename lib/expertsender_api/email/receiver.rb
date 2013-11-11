module ExpertSenderApi::Email
  class Receiver
    include ::ExpertSenderApi::Serializeable
    attr_accessor :id, :email, :list_id

    def initialize(parameters = {})
      parameters.each { |key, value| send("#{key}=", value) }
    end

    def insert_to(xml)
      xml.Receiver {
        attributes.each do |attr|
          xml.send(attr[:name], attr[:value]) unless attr[:value].nil?
        end
      }
    end
  end
end




