module APNS
  require 'socket'
  require 'openssl'
  require 'json'

  @host = 'gateway.sandbox.push.apple.com'
  @port = 2195

  class << self
    attr_accessor :host, :cert, :key, :port, :pass

    def send_notification(device_token, message)
      n = APNS::Notification.new(device_token, message)
      self.send_notifications([n])
    end

    def send_notifications(notifications)
      sock, ssl = self.open_connection

      packed_nofications = self.packed_nofications(notifications)

      notifications.each do |n|
        ssl.write(packed_nofications)
      end

      ssl.close
      sock.close
    end

    def packed_nofications(notifications)
      bytes = ''

      notifications.each do |notification|
        # Each notification frame consists of
        # 1. (e.g. protocol version) 2 (unsigned char [1 byte])
        # 2. size of the full frame (unsigend int [4 byte], big endian)
        pn = notification.packaged_notification
        bytes << ([2, pn.bytesize].pack('CN') + pn)
      end

      bytes
    end

    def feedback
      sock, ssl = self.feedback_connection

      apns_feedback = []

      while message = ssl.read(38)
        timestamp, token_size, token = message.unpack('N1n1H*')
        apns_feedback << [Time.at(timestamp), token]
      end

      ssl.close
      sock.close

      apns_feedback
    end

    def cert=(pem)
      @cert = if pem.respond_to?(:read)
        pem.read
      else
        File.read(pem)
      end
    end

    def key=(pem)
      @key = if pem.respond_to?(:read)
        pem.read
      else
        File.read(pem)
      end
    end

    protected

    def ssl_context
      context      = OpenSSL::SSL::SSLContext.new
      context.cert = OpenSSL::X509::Certificate.new(cert)
      context.key  = OpenSSL::PKey::RSA.new(key, self.pass)
      context
    end

    def open_connection
      sock         = TCPSocket.new(self.host, self.port)
      ssl          = OpenSSL::SSL::SSLSocket.new(sock, ssl_context)
      ssl.connect

      [sock, ssl]
    end

    def feedback_connection
      fhost = self.host.gsub('gateway','feedback')

      sock         = TCPSocket.new(fhost, 2196)
      ssl          = OpenSSL::SSL::SSLSocket.new(sock, ssl_context)
      ssl.connect

      [sock, ssl]
    end

  end
end
