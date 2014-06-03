require "ipaddr"
require_relative "subnet/load_balancer"
require_relative "subnet/gateway"
require_relative "subnet/database"
require_relative "subnet/web"

class Akashi
  class AWS
    class EC2
      class Subnet < Akashi::AWS::EC2::Base
        class << self
          def next_cidr_block(vpc)
            IPAddr.new(latest_cidr_block.to_i + step, Socket::AF_INET).to_s + "/#{cidr}"
          end

          def latest_cidr_block(vpc)
            all(vpc).map{ |subnet| IPAddr.new(subnet.cidr_block) }.max
          end

          def all(vpc)
            Akashi::AWS.instance.ec2.subnets.select do |subnet|
              subnet.vpc_id == vpc.id && base_cidr_block.include?(subnet.cidr_block)
            end
          end

          def step
            @step ||= (~netmask).succ.to_i
          end

          def netmask
            @netmask ||= IPAddr.new("0b#{netmask_binary}".oct, Socket::AF_INET)
          end

          def netmask_binary
            @netmask_bainary ||= ("1" * cidr).ljust(32, "0")
          end

          def cidr
            @cidr ||= 24
          end
        end

        def create!(vpc: , availability_zone: )
          response = @ec2.client.create_subnet(
            vpc_id:            vpc.id,
            availability_zone: availability_zone,
            cidr_block:        self.class.next_cidr_block(vpc),
          )
          id = response[:subnet][:subnet_id]
        end

        def associate_with_route_table!(route_table)
          @ec2.client.associate_route_table(subnet_id: id, route_table_id: route_table.id)
        end

        def exists?
          @ec2.subnets.any? { |subnet| subnet.id == id }
        end
      end
    end
  end
end
