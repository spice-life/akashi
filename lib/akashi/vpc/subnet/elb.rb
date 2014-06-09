module Akashi
  class Vpc
    class Subnet
      class Elb < Akashi::Vpc::Subnet::Base
        class << self
          def cidr_block
            @cidr_block ||= IPAddr.new("10.0.0.0/19")
          end
        end
      end
    end
  end
end