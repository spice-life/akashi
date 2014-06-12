module Akashi
  class Elb
    class LoadBalancer < Akashi::Elb::Base
      def_delegators :@object, :dns_name, :name, :subnet_ids, :configure_health_check

      def modify_attributes(options)
        Akashi::Aws.elb.client.
          modify_load_balancer_attributes(options.merge({ load_balancer_name: name }))
      end

      class << self
        def create(security_group:, subnets:, ssl_certificate:)
          Akashi::Aws.elb.client.create_load_balancer(
            load_balancer_name: Akashi.name,
            security_groups:    [ security_group.id ],
            subnets:            Array.wrap(subnets).map(&:id),
            listeners:          [
              {
                protocol:           "HTTPS",
                load_balancer_port: 443,
                instance_protocol:  "HTTP",
                instance_port:      80,
                ssl_certificate_id: ssl_certificate.arn,
              }
            ],
          )

          new(Akashi.name).tap do |instance|
            instance.modify_attributes(
              load_balancer_attributes: {
                cross_zone_load_balancing: {
                  enabled: true,
                },
                connection_draining: {
                  enabled: true,
                  timeout: 300,
                },
              },
            )
            instance.configure_health_check(
              target:              Akashi.manifest.elb.health_check.target,
              interval:            60,
              timeout:             30,
              unhealthy_threshold: 2,
              healthy_threshold:   2,
            )
            puts "Created a LoadBalancer(#{instance.name})."
          end
        end
      end
    end
  end
end
