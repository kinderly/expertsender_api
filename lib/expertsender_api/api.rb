module ExpertSenderApi
  class API
    include HTTParty

    class << self
      attr_accessor :api_key, :api_endpoint, :throws_exceptions
    end

    attr_accessor :api_key, :api_endpoint, :throws_exceptions

    SUBSCRIBER_INFO_OPTION_SHORT = 1
    SUBSCRIBER_INFO_OPTION_MEDIUM = 2
    SUBSCRIBER_INFO_OPTION_FULL = 3

    XML_NAMESPACES = { 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                       'xmlns:xs' => 'http://www.w3.org/2001/XMLSchema' }

    def initialize(key: nil, **parameters)
      @api_key = key || self.class.api_key || ENV['EXPERTSENDER_API_KEY']
      @api_key = @api_key.strip if @api_key

      @throws_exceptions = parameters.has_key?(:throws_exceptions) ? parameters.delete(:throws_exceptions) : self.class.throws_exceptions
      @api_endpoint = parameters.delete(:api_endpoint) || self.class.api_endpoint

      unless api_endpoint.nil?
        @subscribers_url = api_endpoint + '/Api/Subscribers'
        @removed_subscribers_url = api_endpoint + '/Api/RemovedSubscribers'
        @newsletters_url = api_endpoint + '/Api/Newsletters'
        @transactionals_url = api_endpoint + '/Api/Transactionals'
      end
    end

    def add_subscriber_to_list(subscriber)
      add_subscribers_to_list([subscriber])
    end

    def add_subscribers_to_list(subscribers)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.ApiRequest(XML_NAMESPACES) {
          xml.ApiKey api_key
          xml.MultiData {
            subscribers.each { |subscriber| subscriber.insert_to(xml) }
          }
        }
      end

      xml = builder.to_xml save_with: Nokogiri::XML::Node::SaveOptions::NO_DECLARATION
      response = self.class.post(@subscribers_url, body: xml)

      handle_response(response)
    end

    def remove_subscriber_from_list(options)
      email = options.delete :email
      id = options.delete :id

      response = id.nil? ? remove_subscriber_by_email(email, options) : remove_subscriber_by_id(id, options)

      handle_response(response)
    end

    def get_subscriber_info(option: SUBSCRIBER_INFO_OPTION_FULL, email: nil)
      params = { apiKey: api_key, email: email, option: option }

      response = self.class.get(@subscribers_url, query: params)

      handle_response(response)
    end

    def update_subscriber(email, subscriber)
      result = get_subscriber_info(email: email)

      return result if result.failed?

      expertsender_id = result.parsed_response.xpath('//Data/Id').text
      list_ids = result.parsed_response.xpath('//StateOnList/ListId').map(&:text)

      subscriber.id = expertsender_id

      list_ids.each do |list_id|
        subscriber.list_id = list_id
        res = add_subscriber_to_list(subscriber)
      end

      result
    end

    def add_or_update_subscriber(email, subscriber)
      result = update_subscriber(email, subscriber)

      return add_subscriber_to_list(subscriber) if result.failed?

      result
    end

    def create_and_send_email(options)
      recipients = options.delete :recipients
      content = options.delete :content

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.ApiRequest(XML_NAMESPACES) {
          xml.ApiKey api_key
          xml.Data {
            recipients.insert_to xml
            content.insert_to xml
          }
        }
      end

      xml = builder.to_xml save_with: Nokogiri::XML::Node::SaveOptions::NO_DECLARATION
      response = self.class.post(@newsletters_url, body: xml)

      handle_response(response)
    end

    def send_transaction_email(options)
      letter_id = options.delete :letter_id
      receiver = options.delete :receiver
      snippets = options.delete :snippets

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.ApiRequest(XML_NAMESPACES) {
          xml.ApiKey api_key
          xml.Data {
            receiver.insert_to xml
            if snippets.any?
              xml.Snippets {
                snippets.each { |snippet| snippet.insert_to(xml) }
              }
            end
          }
        }
      end

      xml = builder.to_xml save_with: Nokogiri::XML::Node::SaveOptions::NO_DECLARATION
      response = self.class.post("#{@transactionals_url}/#{letter_id}", body: xml)

      handle_response(response)
    end

    def get_deleted_subscribers(options = {})
      params = { apiKey: api_key }

      list_ids =  options[:list_ids]
      remove_types =  options[:remove_types]
      start_date = options[:start_date]
      end_date = options[:end_date]

      params[:listIds] = list_ids.join(',') if list_ids.respond_to?(:any?)
      params[:removeTypes] = remove_types.join(',') if remove_types.respond_to?(:any?)
      params[:startDate] = start_date.to_s unless start_date.nil?
      params[:endDate] = end_date.to_s unless end_date.nil?

      response = self.class.get(@removed_subscribers_url, query: params)

      handle_response(response)
    end

    private

    def handle_response(response)
      result = Result.new(response)

      if should_raise_for_response?(result)
        error = ExpertSenderError.new("ExpertSender API Error: #{result.error_message} (code #{result.error_code})")
        error.code = result.error_code
        raise error
      end

      result
    end

    def should_raise_for_response?(result)
      @throws_exceptions and result.failed?
    end

    def remove_subscriber_by_email(email, options = {})
      params = options.merge({ apiKey: api_key, email: email })

      self.class.delete(@subscribers_url, query: params)
    end

    def remove_subscriber_by_id(id, options = {})
      params = options.merge({ apiKey: api_key })

      self.class.delete("#{@subscribers_url}/#{id}", query: params)
    end
  end
end

