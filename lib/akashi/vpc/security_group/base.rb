module Akashi
  class Vpc
    class SecurityGroup
      class Base < Akashi::Vpc::SecurityGroup
        class << self
          def all
            super.select { |security_group| security_group.name.end_with?(name_suffix) }
          end

          def create(vpc:)
            response = Akashi::Aws.ec2.client.create_security_group(
              vpc_id:      vpc.id,
              group_name:  name,
              description: name,
            )
            id     = response[:group_id]
            object = find(id)

            ingress_ip_permissions.each do |ip|
              object.authorize_ingress(ip[:protocol], ip[:port], *ip[:sources])
            end

            new(object)
          end

          def name
            "#{Akashi.name}-#{name_suffix}"
          end
        end
      end
    end
  end
end
