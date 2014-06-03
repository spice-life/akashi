class Infrastructure
  class AWS
    class EC2
      class Subnet
        class Web < Infrastructure::AWS::EC2::Subnet
          class << self
            def base_cidr_block
              @base_cidr_block ||= IPAddr.new("10.0.96.0/19")
            end
          end
        end
      end
    end
  end
end
