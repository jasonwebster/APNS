require File.dirname(__FILE__) + '/../spec_helper'
require 'stringio'

describe APNS do
  subject { APNS }

  let(:pem_path) { File.expand_path(File.join(File.dirname(__FILE__), '../fixtures/sample.pem')) }

  describe '#pem_contents' do
    it 'should raise an error if pem is unset' do
      expect { APNS.send(:pem_contents) }.to raise_error
    end

    it 'should be able to read from a file' do
      APNS.pem = pem_path
      expect { APNS.send(:pem_contents) }.to_not raise_error
    end

    it 'should be able to read from a StringIO object' do
      APNS.pem = StringIO.new(File.read(pem_path))
      expect { APNS.send(:pem_contents) }.to_not raise_error
    end
  end
end
