module ExpertSenderApi
  class Subscriber
    MODE_ADD_AND_UPDATE = 'AddAndUpdate'
    MODE_ADD_AND_REPLACE = 'AddAndReplace'
    MODE_ADD_AND_IGNORE = 'AddAndIgnore'
    MODE_IGNORE_AND_UPDATE = 'IgnoreAndUpdate'
    MODE_IGNORE_AND_REPLACE = 'IgnoreAndReplace'

    class << self
      attr_accessor :mode, :force, :list_id
    end

    attr_accessor :mode, :force, :list_id, :id, :email, :firstname, :lastname,
                  :tracking_code, :name, :vendor, :ip, :properties

    def initialize(mode: MODE_ADD_AND_UPDATE, **parameters)
      @mode = mode || self.class.mode
      @force = parameters[:force] || self.class.force
      @list_id = parameters[:list_id] || self.class.list_id

      parameters.each { |key, value| send("#{key}=", value) }
    end

    def insert_to(xml)
      xml.Subscriber {
        attributes.each do |attr|
          xml.send(attr[:name], attr[:value]) unless attr[:value].nil?
        end
      }
    end

    private

    def attributes
      instance_variables.map do |ivar|
        { name: camel_case(ivar.to_s[1..-1]), value: instance_variable_get(ivar) }
      end
    end

    def camel_case(str)
      str.split(/[\W_]/).map {|c| c.capitalize}.join
    end
  end
end

