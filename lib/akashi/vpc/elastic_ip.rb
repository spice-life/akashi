module Akashi
  class Vpc
    class ElasticIp < Akashi::Vpc::Base
      def_delegators :@object, :public_ip, :associate

      def associate(instance:)
        @object.associate(instance: instance.id)
        puts "An Elastic IP (#{public_ip}) associated with an EC2 Instance (#{instance.id})."
      end

      class << self
        def create
          response = Akashi::Aws.ec2.client.allocate_address(domain: "vpc")

          new(response[:public_ip]).tap do |instance|
            puts "Created an Elastic IP (#{instance.public_ip})."
          end
        end
      end
    end
  end
end
