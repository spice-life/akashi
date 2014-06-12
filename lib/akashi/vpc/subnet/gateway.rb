module Akashi
  class Vpc
    class Subnet
      class Gateway < Akashi::Vpc::Subnet::Base
        class << self
          def base_cidr_block
            @base_cidr_block ||= IPAddr.new("10.0.32.0/19")
          end
        end
      end
    end
  end
end
