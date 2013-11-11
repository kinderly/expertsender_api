require 'spec_helper'

describe ExpertSenderApi::Email::Recipients do
  context :with_valid_attributes do
    let(:valid_attributes) { { subscriber_lists: [53, 53] } }

    subject do
      ExpertSenderApi::Email::Recipients.new valid_attributes
    end

    it 'has proper attributes' do
      valid_attributes.each do |key, value|
        subject.send(key).should eq value
      end
    end

    it 'generates proper markup' do
      builder = Nokogiri::XML::Builder.new do |xml|
        subject.insert_to(xml)
      end

      xml = Nokogiri::XML(builder.to_xml)

      xml.xpath('//SubscriberLists/SubscriberList').map(&:text).should eq valid_attributes[:subscriber_lists].map(&:to_s)
    end
  end
end



