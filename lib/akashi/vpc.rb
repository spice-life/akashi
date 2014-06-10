require "akashi/vpc/base"
require "akashi/vpc/internet_gateway"
require "akashi/vpc/route_table"
require "akashi/vpc/security_group"
require "akashi/vpc/subnet"

module Akashi
  class Vpc < Akashi::Vpc::Base
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

      def base_class
        @base_class ||= ::AWS::EC2::VPC
      end

      def attributes
        @attributes ||= [
          :cidr_block,
          :instance_tenancy,
          :state,
        ]
      end
    end
  end
end
