require 'spec_helper'

describe ExpertSenderApi::Result do
  it 'should be successful if response code is 204' do
    response = double('response', code: 204, body: '', headers: {})
    result = ExpertSenderApi::Result.new(response)

    expect(result.status_success?).to be true
  end
end
