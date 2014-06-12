require "base64"

module Akashi
  class Ec2
    class KeyPair < Akashi::Ec2::Base
      def_delegators :@object, :fingerprint, :name

      class << self
        def create(public_key)
          response = Akashi::Aws.ec2.client.import_key_pair(
            key_name:            Akashi.name,
            public_key_material: Base64.encode64(public_key)
          )

          new(response[:key_name]).tap do |instance|
            puts "Created a KeyPair (#{instance.id})."
          end
        end
      end
    end
  end
end
