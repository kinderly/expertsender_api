require 'spec_helper'

describe ExpertSenderApi::Subscriber::Tag do
  context :with_valid_attributes do
    let(:properties) { [ExpertSenderApi::Subscriber::Property.new(id: 123,
                                                                  value: 'test',
                                                                  type: 'string'),
                        ExpertSenderApi::Subscriber::Property.new(id: 456,
                                                                  value: 'test1',
                                                                  type: 'string')] }
    let(:valid_attributes) { { list_id: 52,
                               email: 'test@httplab.ru',
                               mode: ExpertSenderApi::Subscriber::Tag::MODE_ADD_AND_IGNORE,
                               id: 777,
                               firstname: 'Test1',
                               lastname: 'Test2',
                               name: 'Test3',
                               tracking_code: '123',
                               vendor: 'Vendor',
                               ip: '127.0.0.1',
                               properties: properties } }

    subject do
      ExpertSenderApi::Subscriber::Tag.new valid_attributes
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

      xml.xpath('//Subscriber/ListId').text.to_i.should eq valid_attributes[:list_id]
      xml.xpath('//Subscriber/Email').text.should eq valid_attributes[:email]
      xml.xpath('//Subscriber/Mode').text.should eq valid_attributes[:mode]
      xml.xpath('//Subscriber/Id').text.to_i.should eq valid_attributes[:id]
      xml.xpath('//Subscriber/Firstname').text.should eq valid_attributes[:firstname]
      xml.xpath('//Subscriber/Lastname').text.should eq valid_attributes[:lastname]
      xml.xpath('//Subscriber/Name').text.should eq valid_attributes[:name]
      xml.xpath('//Subscriber/TrackingCode').text.should eq valid_attributes[:tracking_code]
      xml.xpath('//Subscriber/Vendor').text.should eq valid_attributes[:vendor]
      xml.xpath('//Subscriber/Ip').text.should eq valid_attributes[:ip]

      properties.each_with_index do |property, i|
        xml_prop = xml.xpath('//Subscriber/Properties/Property')[i]
        xml_prop.xpath('Id').text.to_i.should eq property.id
        xml_prop.xpath('Value').attribute('xsi:type').value.should eq "xs:#{property.type}"
        xml_prop.xpath('Value').text.should eq property.value
      end
    end
  end
end

