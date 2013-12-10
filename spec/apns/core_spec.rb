require File.dirname(__FILE__) + '/../spec_helper'
require 'stringio'

describe APNS do
  subject { APNS }

  let(:pem_path) { File.expand_path(File.join(File.dirname(__FILE__), '../fixtures/sample.pem')) }
  let(:pem_contents) { File.read pem_path }

  describe 'reading certificates and keys' do
    it 'should be able to read from a file' do
      APNS.cert = pem_path
      APNS.cert.should eql pem_contents
    end

    it 'should be able to read from a StringIO object' do
      APNS.cert = StringIO.new(File.read(pem_path))
      APNS.cert.should eql pem_contents
    end
  end
end
