require 'spec_helper'

describe ExpertSenderApi::Email::Receiver do
  context :with_valid_attributes do
    let(:valid_attributes) { { id: '777',
                               email: 'test@test.com',
                               list_id: '53' } }

    subject do
      ExpertSenderApi::Email::Receiver.new valid_attributes
    end

    it 'has proper attributes' do
      subject.id.should eq valid_attributes[:id]
      subject.email.should eq valid_attributes[:email]
      subject.list_id.should eq valid_attributes[:list_id]
    end

    it 'generates proper markup' do
      builder = Nokogiri::XML::Builder.new do |xml|
        subject.insert_to(xml)
      end

      xml = Nokogiri::XML(builder.to_xml)

      xml.xpath('//Receiver/Id').text.should eq valid_attributes[:id]
      xml.xpath('//Receiver/Email').text.should eq valid_attributes[:email]
      xml.xpath('//Receiver/ListId').text.should eq valid_attributes[:list_id]
    end
  end
end


