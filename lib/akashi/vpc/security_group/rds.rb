module Akashi
  class Vpc
    class SecurityGroup
      class Rds < Akashi::Vpc::SecurityGroup::Base
        class << self
          def ingress_ip_permissions
            @ingress_ip_permissions ||= [
              {
                protocol: :tcp,
                port:     3306,
                sources:  [
                  "10.0.96.0/19",
                ],
              },
            ]
          end

          def name_suffix
            @name_suffix ||= "-rds"
          end
        end
      end
    end
  end
end
