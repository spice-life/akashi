module Akashi
  class Vpc
    class Subnet
      class WebServer < Akashi::Vpc::Subnet::Base
        class << self
          def cidr_block
            @cidr_block ||= IPAddr.new("10.0.96.0/19")
          end

          def name_suffix
            @name_suffix ||= "web-server"
          end
        end
      end
    end
  end
end
