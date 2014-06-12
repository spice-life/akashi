require "openssl"

module Akashi
  class Elb
    class SslCertificate < Akashi::Elb::Base
      def_delegators :@object, :arn, :name, :delete

      class << self
        def create
          ssl_certificate = Akashi.manifest.elb.ssl_certificate

          certificate_chain  = ssl_certificate.certificate_chain
          private_key_path   = ssl_certificate.private_key_path
          server_certificate = ssl_certificate.server_certificate

          options = {
            certificate_body:        server_certificate,
            private_key:             OpenSSL::PKey::RSA.new(File.read(private_key_path)).to_pem,
            server_certificate_name: Akashi.name,
          }
          options.merge!({ certificate_chain: certificate_chain }) if !!certificate_chain

          response = Akashi::Aws.iam.client.upload_server_certificate(options)

          new(response[:server_certificate_metadata][:server_certificate_name]).tap do |instance|
            puts "Created a SSL Certificate (#{instance.name})."
          end
        end

        def all
          collection.map { |object| new(object.name) }
        end

        def service_class
          @service_class ||= "IAM"
        end

        def object_class
          @object_class ||= "ServerCertificate"
        end
      end
    end
  end
end
