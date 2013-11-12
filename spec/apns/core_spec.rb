require File.dirname(__FILE__) + '/../spec_helper'
require 'stringio'

describe APNS do
  subject { APNS }

  let(:pem_path) { File.expand_path(File.join(File.dirname(__FILE__), '../fixtures/sample.pem')) }

  describe '#read_cert' do
    it 'should raise an error if cert is unset' do
      expect { APNS.send(:read_cert) }.to raise_error
    end

    it 'should be able to read from a file' do
      APNS.cert = pem_path
      expect { APNS.send(:read_cert) }.to_not raise_error
    end

    it 'should be able to read from a StringIO object' do
      APNS.cert = StringIO.new(File.read(pem_path))
      expect { APNS.send(:read_cert) }.to_not raise_error
    end
  end
end
