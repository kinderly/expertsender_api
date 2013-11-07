require 'spec_helper'

describe ExpertSenderApi::API do
  let(:api_key) { "123-us1" }
  let(:api_endpoint) { 'https://api2.esv2.com' }
  let(:subscriber_attributes) { { id: 1, list_id: 52, email: "test@httplab.ru" } }
  let(:subscribers) { [ExpertSenderApi::Subscriber.new(subscriber_attributes)] }

  describe "attributes" do
    it "have no API key by default" do
      having_env('EXPERTSENDER_API_KEY', nil) { @expertsender = ExpertSenderApi::API.new }
      expect(@expertsender.api_key).to be_nil
    end

    it "set an API key in constructor" do
      @expertsender = ExpertSenderApi::API.new(key: api_key)
      expect(@expertsender.api_key).to eq(api_key)
    end

    it "set an API key from the 'EXPERTSENDER_API_KEY' ENV variable" do
      having_env('EXPERTSENDER_API_KEY', api_key) { @expertsender = ExpertSenderApi::API.new }
      expect(@expertsender.api_key).to eq(api_key)
    end

    it "set an API key via setter" do
      @expertsender = ExpertSenderApi::API.new
      @expertsender.api_key = api_key
      expect(@expertsender.api_key).to eq(api_key)
    end

    it "detect api endpoint from initializer parameters" do
      @expertsender = ExpertSenderApi::API.new(key: api_key, api_endpoint: api_endpoint)
      expect(api_endpoint).to eq(@expertsender.api_endpoint)
    end

    it "sets the 'throws_exceptions' option from initializer parameters" do
      @expertsender = ExpertSenderApi::API.new(key: api_key, throws_exceptions: false)
      expect(false).to eq(@expertsender.throws_exceptions)
    end
  end

  describe "ExpertSenderApi class variables" do
    before do
      ExpertSenderApi::API.api_key = "123-us1"
      ExpertSenderApi::API.throws_exceptions = false
      ExpertSenderApi::API.api_endpoint = api_endpoint
    end

    after do
      ExpertSenderApi::API.api_key = nil
      ExpertSenderApi::API.throws_exceptions = nil
      ExpertSenderApi::API.api_endpoint = nil
    end

    it "set api key on new instances" do
      expect(ExpertSenderApi::API.new.api_key).to eq(ExpertSenderApi::API.api_key)
    end

    it "set throws_exceptions on new instances" do
      expect(ExpertSenderApi::API.new.throws_exceptions).to eq(ExpertSenderApi::API.throws_exceptions)
    end

    it "set api_endpoint on new instances" do
      expect(ExpertSenderApi::API.api_endpoint).not_to be_nil
      expect(ExpertSenderApi::API.new.api_endpoint).to eq(ExpertSenderApi::API.api_endpoint)
    end
  end

  context 'when configured properly' do
    subject { ExpertSenderApi::API.new key: api_key, api_endpoint: api_endpoint }

    its '#add_subscribers_to_list calls post with correct body' do
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.ApiRequest {
          xml.ApiKey api_key
          xml.MultiData {
            subscribers.each { |subscriber| subscriber.insert_to(xml) }
          }
        }
      end

      xml = builder.to_xml save_with: Nokogiri::XML::Node::SaveOptions::NO_DECLARATION

      expect_post("#{api_endpoint}/Api/Subscribers", xml)
      subject.add_subscribers_to_list(subscribers)
    end

    its '#remove_subscriber_from_list by id calls delete with correct parameters' do
      expected_params = { apiKey: api_key, listId: subscriber_attributes[:list_id] }
      expect_delete("#{api_endpoint}/Api/Subscribers/#{subscriber_attributes[:id]}", expected_params)

      subject.remove_subscriber_from_list(id: subscriber_attributes[:id], listId: subscriber_attributes[:list_id])
    end

    its '#remove_subscriber_from_list by email returns success response' do
      expected_params = { apiKey: api_key, email: subscriber_attributes[:email], listId: subscriber_attributes[:list_id] }
      expect_delete("#{api_endpoint}/Api/Subscribers", expected_params)

      subject.remove_subscriber_from_list(email: subscriber_attributes[:email], listId: subscriber_attributes[:list_id])
    end
  end

  context 'when has wrong api key' do
    subject { ExpertSenderApi::API.new key: 'wrong', api_endpoint: api_endpoint, throws_exceptions: true }

    its '#add_subscribers_to_list raises exception' do
      expect { subject.add_subscribers_to_list(subscribers) }.to raise_error(ExpertSenderApi::ExpertSenderError)
    end
  end

  private

  def having_env(key, value)
    prev_value = ENV[key]
    ENV[key] = value
    yield
    ENV[key] = prev_value
  end

  def expect_post(expected_url, expected_body)
    ExpertSenderApi::API.should_receive(:post).with do |url, opts|
      expect(url).to eq expected_url
      expect(expected_body).to eq opts[:body]
    end.and_return(Struct.new(:body).new(nil))
  end

  def expect_delete(expected_url, expected_params)
    ExpertSenderApi::API.should_receive(:delete).with do |url, opts|
      expect(url).to eq expected_url
      expect(expected_params).to eq opts[:query]
    end.and_return(Struct.new(:body).new(nil))
  end
end

