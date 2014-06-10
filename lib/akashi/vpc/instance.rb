module Akashi
  class Vpc
    class Instance < Akashi::Vpc::Base
      def_delegators :@object, :cidr_block, :instance_tenancy, :state

      def internet_gateway=(internet_gateway)
        @object.internet_gateway = internet_gateway.id
        puts "Attached an InternetGateway (#{internet_gateway.id}) to a VPC (#{id})."
      end

      class << self
        def create
          response = Akashi::Aws.ec2.client.create_vpc(
            cidr_block:       "10.0.0.0/16",
            instance_tenancy: "default",
          )
          id = response[:vpc][:vpc_id]

          new(id).tap do |instance|
            instance.name = Akashi.name
            puts "Created a VPC (#{id})."
          end
        end

        def object_class
          @object_class ||= "VPC"
        end
      end
    end
  end
end
