module Akashi
  class Vpc
    class SecurityGroup
      class WebServer < Akashi::Vpc::SecurityGroup::Base
        class << self
          def ingress_ip_permissions
            @ingress_ip_permissions ||= [
              {
                protocol: :tcp,
                port:     80,
                sources:  [
                  "10.0.0.0/19",
                ],
              },
              {
                protocol: :tcp,
                port:     9922,
                sources:  [
                  "10.0.32.0/19",
                ],
              },
              {
                protocol: :icmp,
                port:     -1,
                sources:  [
                  "10.0.32.0/19",
                ],
              },
            ]
          end

          def name_suffix
            @name_suffix ||= "web-server"
          end
        end
      end
    end
  end
end
