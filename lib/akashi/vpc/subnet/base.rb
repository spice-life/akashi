require "ipaddr"

module Akashi
  class Vpc
    class Subnet
      class Base < Akashi::Vpc::Subnet
        class << self
          def all
            super.select { |subnet| cidr_block.include?(subnet.cidr_block) }
          end

          def create(vpc:, availability_zone:)
            response = Akashi::Aws.ec2.client.create_subnet(
              vpc_id:            vpc.id,
              availability_zone: availability_zone,
              cidr_block:        next_cidr_block(vpc: vpc).to_s + "/#{cidr}",
            )
            id = response[:subnet][:subnet_id]
            new(id).tap do |instance|
              instance.name = name
              puts "Created #{id}"
            end
          end

          def next_number(vpc:)
            "%02d" % (where(vpc_id: vpc.id).count + 1)
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
          # netmask.to_s   #=> "255.255.255.0"
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

          def name
            "#{Akashi.name}-#{name_suffix}-#{next_number}"
          end
        end
      end
    end
  end
end
