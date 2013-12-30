module ExpertSenderApi::Subscriber
  class Tag
    include ::ExpertSenderApi::Serializeable

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
      @properties = parameters.delete(:properties) || []

      parameters.each { |key, value| send("#{key}=", value) }
    end

    def insert_to(xml)
      xml.Subscriber {
        attributes.each do |attr|
          xml.send(attr[:name], attr[:value]) unless attr[:value].nil?
        end
        if properties.any?
          xml.Properties {
            properties.each { |property| property.insert_to(xml) }
          }
        end
      }
    end

    private

    def variables_to_serialize
      instance_variables.select { |var| var != :@properties }
    end
  end
end

