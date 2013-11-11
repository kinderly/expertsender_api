require 'spec_helper'

describe ExpertSenderApi::Email::Content do
  context :with_valid_attributes do
    let(:valid_attributes) { { from_name: 'From Name Test',
                               from_email: 'test@httplab.ru',
                               reply_to_name: 'Reply To Name Test',
                               reply_to_email: 'Reply To Email Test',
                               subject: 'Subject test',
                               html: 'Html Test Content',
                               plain: 'Plain Test Content' } }

    subject do
      ExpertSenderApi::Email::Content.new valid_attributes
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

      xml.xpath('//FromName').text.should eq valid_attributes[:from_name]
      xml.xpath('//FromEmail').text.should eq valid_attributes[:from_email]
      xml.xpath('//ReplyToName').text.should eq valid_attributes[:reply_to_name]
      xml.xpath('//ReplyToEmail').text.should eq valid_attributes[:reply_to_email]
      xml.xpath('//Subject').text.should eq valid_attributes[:subject]
      xml.xpath('//Html').text.should eq valid_attributes[:html]
      xml.xpath('//Plain').text.should eq valid_attributes[:plain]
    end
  end
end


