module Akashi
  class VPC < Akashi::VPC::Base
    class << self
      def create
        response = Akashi::AWS.ec2.client.create_vpc(
          cidr_block:       "10.0.0.0/16",
          instance_tenancy: "default",
        )
        new(find(response[:vpc][:vpc_id]))
      end
    end
  end
end
