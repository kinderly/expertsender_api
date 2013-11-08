require 'expertsender_api/subscriber'
require 'expertsender_api/result'
require 'expertsender_api/expertsender_error'

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

    def initialize(key: nil, **parameters)
      @api_key = key || self.class.api_key || ENV['EXPERTSENDER_API_KEY']
      @api_key = @api_key.strip if @api_key

      @throws_exceptions = parameters.has_key?(:throws_exceptions) ? parameters.delete(:throws_exceptions) : self.class.throws_exceptions
      @api_endpoint = parameters.delete(:api_endpoint) || self.class.api_endpoint

      @subscribers_url = api_endpoint.concat('/Api/Subscribers') unless api_endpoint.nil?
    end

    def add_subscriber_to_list(subscriber)
      add_subscribers_to_list([subscriber])
    end

    def add_subscribers_to_list(subscribers)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.ApiRequest {
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

    def update_subscriber_email(email, new_email)
      info = get_subscriber_info(email: email)

      return info if info.failed?

      expertsender_id = info.parsed_response.xpath('//Data/Id').text
      list_ids = info.parsed_response.xpath('//StateOnList/ListId').map(&:text)

      list_ids.each do |list_id|
        add_subscriber_to_list(Subscriber.new list_id: list_id,
                                              id: expertsender_id,
                                              email: new_email)
      end
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

