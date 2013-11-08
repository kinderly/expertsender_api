require 'spec_helper'

describe ExpertSenderApi::Subscriber do
  context :with_valid_attributes do
    let(:valid_attributes) { { list_id: 52,
                               email: 'test@httplab.ru',
                               mode: ExpertSenderApi::Subscriber::MODE_ADD_AND_IGNORE,
                               id: 777,
                               firstname: 'Test1',
                               lastname: 'Test2',
                               name: 'Test3',
                               tracking_code: '123',
                               vendor: 'Vendor',
                               ip: '127.0.0.1' } }

    subject do
      ExpertSenderApi::Subscriber.new valid_attributes
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

      xml.xpath('//ListId').text.to_i.should eq valid_attributes[:list_id]
      xml.xpath('//Email').text.should eq valid_attributes[:email]
      xml.xpath('//Mode').text.should eq valid_attributes[:mode]
      xml.xpath('//Id').text.to_i.should eq valid_attributes[:id]
      xml.xpath('//Firstname').text.should eq valid_attributes[:firstname]
      xml.xpath('//Lastname').text.should eq valid_attributes[:lastname]
      xml.xpath('//Name').text.should eq valid_attributes[:name]
      xml.xpath('//TrackingCode').text.should eq valid_attributes[:tracking_code]
      xml.xpath('//Vendor').text.should eq valid_attributes[:vendor]
      xml.xpath('//Ip').text.should eq valid_attributes[:ip]
    end
  end
end

