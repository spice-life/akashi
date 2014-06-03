class Infrastructure
  class AWS
    class EC2
      class VPC < Infrastructure::AWS::EC2::Base
        def create!
          response = @ec2.client.create_vpc(cidr_block: "10.0.0.0/16", instance_tenancy: "default")
          id = response[:vpc][:vpc_id]
        end
      end
    end
  end
end
