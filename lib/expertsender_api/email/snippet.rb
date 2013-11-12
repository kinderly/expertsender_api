module ExpertSenderApi::Email
  class Snippet
    attr_accessor :name, :value, :cdata

    def initialize(name: nil, value: nil, cdata: true)
      @name = name
      @value = value
      @cdata = cdata
    end

    def insert_to(xml)
      if !name.empty? and !value.empty?
        xml.Snippet {
          xml.Name name
          if cdata
            xml.Value { xml.cdata value }
          else
            xml.Value value
          end
        }
      end
    end
  end
end



