require 'expertsender_api/subscriber'
require 'expertsender_api/expertsender_error'

module ExpertSenderApi
  class API
    include HTTParty

    class << self
      attr_accessor :api_key, :api_endpoint, :throws_exceptions
    end

    attr_accessor :api_key, :api_endpoint, :throws_exceptions

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

    private

    def handle_response(response)
      parsed_response = nil

      if (response.body)
        parsed_response = Nokogiri::XML(response.body)

        if should_raise_for_response?(parsed_response)
          message = parsed_response.xpath('//ErrorMessage/Message').text
          code = parsed_response.xpath('//ErrorMessage/Code').text

          error = ExpertSenderError.new("ExpertSender API Error: #{message} (code #{code})")
          error.code = code
          raise error
        end
      end

      parsed_response
    end

    def should_raise_for_response?(response)
      @throws_exceptions && response.xpath('//ErrorMessage').any?
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

