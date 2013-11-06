require 'spec_helper'

describe ExpertSenderApi::API do
  let(:api_endpoint) { 'https://api2.esv2.com' }
  let(:subscriber_attributes) { { list_id: 52, email: "test@httplab.ru" } }
  let(:subscribers) { [ExpertSenderApi::Subscriber.new(subscriber_attributes)] }

  describe "attributes" do
    let(:api_key) { "123-us1" }

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
    subject { ExpertSenderApi::API.new api_endpoint: api_endpoint, throws_exceptions: true }

    its '#add_subscribers_to_list returns success response' do
      response = subject.add_subscribers_to_list(subscribers)
      response.xpath('//ErrorMessage').should be_empty
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
end

