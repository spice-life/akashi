module Akashi
  class Vpc
    class SecurityGroup
      class Base < Akashi::Vpc::Base
        def_delegators :@object, :description, :name, :vpc_id, :authorize_ingress

        class << self
          def all
            super.select { |security_group| security_group.name.end_with?("-#{role}") }
          end

          def create(vpc:)
            response = Akashi::Aws.ec2.client.create_security_group(
              vpc_id:      vpc.id,
              group_name:  name,
              description: name,
            )

            new(response[:group_id]).tap do |instance|
              ingress_ip_permissions.each do |ip_permission|
                instance.authorize_ingress(
                  ip_permission[:protocol],
                  ip_permission[:port],
                  *ip_permission[:sources],
                )
              end
              instance.name = name
              puts "Created a SecurityGroup (#{instance.id}) which role is \"#{role}\"."
            end
          end

          def name
            "#{Akashi.name}-#{role}"
          end

          def role
            self.to_s.demodulize.underscore.dasherize
          end

          def object_class
            @object_class ||= "SecurityGroup"
          end
        end
      end
    end
  end
end
