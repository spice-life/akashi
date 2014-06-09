require "akashi/vpc/base"
require "akashi/vpc/internet_gateway"
require "akashi/vpc/route_table"
require "akashi/vpc/subnet"

module Akashi
  class Vpc < Akashi::Vpc::Base
    class << self
      def internet_gateway=(internet_gateway)
        @object.internet_gateway = internet_gateway.id
      end

      def create
        response = Akashi::Aws.ec2.client.create_vpc(
          cidr_block:       "10.0.0.0/16",
          instance_tenancy: "default",
        )
        new(find(response[:vpc][:vpc_id]))
      end
    end
  end
end
