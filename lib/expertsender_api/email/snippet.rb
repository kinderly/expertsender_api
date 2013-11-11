module ExpertSenderApi::Email
  class Snippet
    attr_accessor :name, :value

    def initialize(name: nil, value: nil)
      @name = name
      @value = value
    end

    def insert_to(xml)
      if !name.empty? and !value.empty?
        xml.Snippet {
          xml.Name name
          xml.Value value
        }
      end
    end
  end
end



