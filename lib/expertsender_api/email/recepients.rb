module ExpertSenderApi::Email
  class Recepients
    attr_accessor :subscriber_lists

    def initialize(subscriber_lists: [])
      @subscriber_lists = subscriber_lists
    end

    def insert_to(xml)
      xml.Recepients {
        if subscriber_lists.any?
          xml.SubscriberLists {
            subscriber_lists.each do |list_id|
              xml.SubscriberList list_id
            end
          }
        end
      }
    end
  end
end


