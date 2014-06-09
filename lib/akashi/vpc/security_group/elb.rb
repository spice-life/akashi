module Akashi
  class Vpc
    class SecurityGroup
      class Elb < Akashi::Vpc::SecurityGroup::Base
        class << self
          def ingress_ip_permissions
            @ingress_ip_permissions ||= [
              {
                protocol: :tcp,
                port:     443,
              }
            ]
          end

          def name_suffix
            @name_suffix ||= "elb"
          end
        end
      end
    end
  end
end
