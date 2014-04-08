require 'csv'

module ExpertSenderApi
  class Result
    attr_reader :response, :parsed_response, :error_code, :error_message
    SUCCESS_CODES = [200, 201, 202, 204].freeze

    def initialize(response)
      @response = response

      if (@response.body)
        content_type = @response.headers['content-type']

        if content_type.include?('xml')
          @parsed_response = Nokogiri::XML(@response.body)

          if @parsed_response.xpath('//ErrorMessage').any?
            @error_message = @parsed_response.xpath('//ErrorMessage/Message').text
            @error_code = @parsed_response.xpath('//ErrorMessage/Code').text
          end
        elsif content_type.include?('csv')
          rows = CSV.parse(@response.body, row_sep: :auto)
          header = rows.shift(1).first

          @parsed_response = []
          rows.each do |row|
            hsh = {}

            header.each_with_index do |column, i|
              hsh[column.to_sym] = row[i]
            end

            @parsed_response << hsh
          end
        end
      end

      freeze
    end

    def success?
      status_success? and
      error_code.nil? and
      error_message.nil?
    end

    def failed?
      not success?
    end

    def status_success?
      SUCCESS_CODES.include?(response.code)
    end
  end
end

