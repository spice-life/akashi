require "ipaddr"

module Akashi
  class VPC
    class Subnet
      class Base < Akashi::VPC::Subnet
        class << self
          def all
            super.select { |subnet| cidr_block.include?(subnet.cidr_block) }
          end

          def create(vpc:, availability_zone:)
            response = Akashi::AWS.ec2.client.create_subnet(
              vpc_id:            vpc.id,
              availability_zone: availability_zone,
              cidr_block:        next_cidr_block(vpc: vpc).to_s + "/#{cidr}",
            )
            new(find(response[:subnet][:subnet_id]))
          end

          def next_cidr_block(vpc:)
            IPAddr.new(latest_cidr_block(vpc: vpc).to_i + step, Socket::AF_INET)
          end

          def latest_cidr_block(vpc:)
            where(vpc_id: vpc.id).map(&:cidr_block).max
          end

          # netmask #=> IPAddr.new(4294967040, Socket::AF_INET)
          # step    #=> 256
          def step
            @step ||= (~netmask).succ.to_i
          end

          # netmask_binary #=> "11111111111111111111111100000000"
          # netmask        #=> IPAddr.new(4294967040, Socket::AF_INET)
          def netmask
            @netmask ||= IPAddr.new("0b#{netmask_binary}".oct, Socket::AF_INET)
          end

          # cidr           #=> 24
          # netmask_binary #=> "11111111111111111111111100000000"
          def netmask_binary
            @netmask_binary ||= ("1" * cidr).ljust(32, "0")
          end

          def cidr
            @cidr ||= 24
          end
        end
      end
    end
  end
end
