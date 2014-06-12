module Akashi
  class Vpc
    class SecurityGroup
      class Gateway < Akashi::Vpc::SecurityGroup::Base
        class << self
          def ingress_ip_permissions
            @ingress_ip_permissions ||= [
              {
                protocol: :tcp,
                port:     9922,
              },
              {
                protocol: :icmp,
                port:     -1,
              },
            ]
          end
        end
      end
    end
  end
end
