module Akashi
  class Vpc
    class Subnet
      class Elb < Akashi::Vpc::Subnet::Base
        class << self
          def base_cidr_block
            @base_cidr_block ||= IPAddr.new("10.0.0.0/19")
          end
        end
      end
    end
  end
end
