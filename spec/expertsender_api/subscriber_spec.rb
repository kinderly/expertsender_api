require 'spec_helper'

describe ExpertSenderApi::Subscriber do
  context :with_valid_attributes do
    let(:valid_attributes) { { list_id: 52, email: 'test@httplab.ru' } }

    subject do
      ExpertSenderApi::Subscriber.new valid_attributes
    end

    it 'has proper attributes' do
      valid_attributes.each do |key, value|
        subject.send(key).should eq value
      end
    end
  end
end

