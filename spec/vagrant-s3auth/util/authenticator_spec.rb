require 'spec_helper'

require 'time'
require 'uri'
require 'vagrant-s3auth/util/authenticator'

describe VagrantPlugins::S3Auth::Util::Authenticator do
  let(:missing_credentials_error) do
    VagrantPlugins::S3Auth::Errors::MissingCredentialsError
  end

  let(:url) { URI.parse('http://google.com') }

  context 'when AWS environment variables are not set' do
    before do
      ENV['AWS_ACCESS_KEY_ID'] = nil
      ENV['AWS_SECRET_ACCESS_KEY'] = nil
    end

    it 'should raise MissingCredentialsError' do
      expect { subject }.to raise_error(missing_credentials_error)
    end
  end

  context 'when AWS environment variables are set' do
    before do
      ENV['AWS_ACCESS_KEY_ID'] = 'AKIAFAKEKEY'
      ENV['AWS_SECRET_ACCESS_KEY'] = 'fakesecretkey'
    end

    before(:example) do
      now = Time.parse('10 March 1991')
      class_double('Time').as_stubbed_const
      allow(Time).to receive('now').and_return(now)
    end

    it 'returns correct auth headers for GET requests' do
      actual = subject.sign(url, 'GET')
      expect(actual).to eql(
        authorization: 'AWS AKIAFAKEKEY:XNzK1Fqy/WKyqpIQxffUQiT8mRA=',
        date: 'Sun, 10 Mar 1991 05:00:00 GMT'
      )
    end

    it 'returns correct auth headers for HEAD requests' do
      actual = subject.sign(url, 'HEAD')
      expect(actual).to eql(
        authorization: 'AWS AKIAFAKEKEY:r89JLa0A7xT4mej+XZbvFODZe0w=',
        date: 'Sun, 10 Mar 1991 05:00:00 GMT'
      )
    end
  end
end
