module ExpertSenderApi::Subscriber
  class Property
    attr_accessor :id, :value, :type

    TYPE_INTEGER = 'int'
    TYPE_STRING = 'string'
    TYPE_DATE = 'date'
    TYPE_DATE_TIME = 'dateTime'
    TYPE_BOOLEAN = 'boolean'

    def initialize(id: nil, value: nil, type: TYPE_STRING)
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




