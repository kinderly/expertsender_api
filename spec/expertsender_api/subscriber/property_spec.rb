require 'spec_helper'

describe ExpertSenderApi::Subscriber::Property do
  context :with_valid_attributes do
    let(:valid_attributes) { { id: 123,
                               type: 'string',
                               value: 'Test Property Value' } }

    subject do
      ExpertSenderApi::Subscriber::Property.new valid_attributes
    end

    it 'has proper attributes' do
      subject.id.should eq valid_attributes[:id]
      subject.type.should eq valid_attributes[:type]
      subject.value.should eq valid_attributes[:value]
    end

    it 'generates proper markup' do
      builder = Nokogiri::XML::Builder.new do |xml|
        subject.insert_to(xml)
      end

      xml = Nokogiri::XML(builder.to_xml)

      xml.xpath('//Property/Id').text.to_i.should eq valid_attributes[:id]
      xml.xpath('//Property/Value').attribute('xsi:type').value.should eq "xs:#{valid_attributes[:type]}"
      xml.xpath('//Property/Value').text.should eq valid_attributes[:value]
    end
  end
end


