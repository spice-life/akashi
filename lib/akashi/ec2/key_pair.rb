module Akashi
  class Ec2
    class KeyPair < Akashi::Ec2::Base
      def_delegators :@object, :fingerprint, :name

      class << self
        def create
          response = Akashi::Aws.ec2.client.import_key_pair(
            key_name:            Akashi.name,
            public_key_material: Akashi.public_key,
          )

          new(response[:key_name]).tap do |instance|
            puts "Created a KeyPair (#{instance.id})."
          end
        end
      end
    end
  end
end
