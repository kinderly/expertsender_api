module ExpertSenderApi
  module Serializeable

    private

    def attributes
      variables_to_serialize.map do |ivar|
        { name: camel_case(ivar.to_s[1..-1]), value: instance_variable_get(ivar) }
      end
    end

    def camel_case(str)
      str.split(/[\W_]/).map {|c| c.capitalize}.join
    end

    def variables_to_serialize
      instance_variables
    end
  end
end

