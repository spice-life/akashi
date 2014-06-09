module Akashi
  class Vpc
    class Subnet
      class SshGateway < Akashi::Vpc::Subnet::Base
        class << self
          def cidr_block
            @cidr_block ||= IPAddr.new("10.0.32.0/19")
          end
        end
      end
    end
  end
end