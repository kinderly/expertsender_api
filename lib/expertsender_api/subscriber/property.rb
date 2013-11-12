module ExpertSenderApi::Subscriber
  class Property
    attr_accessor :id, :value, :type

    def initialize(id: nil, value: nil, type: true)
      @id = id
      @value = value
      @type = type
    end

    def insert_to(xml)
      xml.Property {
        xml.Id id
        xml.Value value, 'xsi:type' => "xs:#{type}"
      }
    end
  end
end




