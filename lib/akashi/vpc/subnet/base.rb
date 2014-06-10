require "ipaddr"

module Akashi
  class Vpc
    class Subnet
      class Base < Akashi::Vpc::Base
        def_delegators :@object, :availability_zone_name,
                                 :available_ip_address_count, :state, :vpc_id

        def cidr_block
          IPAddr.new(@object.cidr_block)
        end

        def route_table=(route_table)
          @object.route_table = route_table.id
          puts "A VPC (#{id}) associated with a RouteTable (#{route_table.id})."
        end

        class << self
          def all
            super.select { |subnet| base_cidr_block.include?(subnet.cidr_block) }
          end

          def create(vpc:, availability_zone:)
            response = Akashi::Aws.ec2.client.create_subnet(
              vpc_id:            vpc.id,
              availability_zone: availability_zone,
              cidr_block:        next_cidr_block(vpc: vpc).to_s + "/#{cidr}",
            )
            id = response[:subnet][:subnet_id]

            new(id).tap do |instance|
              instance.name = name(vpc: vpc)
              puts "Created a Subnet (#{id})."
            end
          end

          def next_number(vpc:)
            "%02d" % (where(vpc_id: vpc.id).count + 1)
          end

          def next_cidr_block(vpc:)
            _latest_cidr_block = latest_cidr_block(vpc: vpc)

            IPAddr.new(
              _latest_cidr_block ? _latest_cidr_block.to_i + step : base_cidr_block.to_s,
              Socket::AF_INET,
            )
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

          def name(vpc:)
            "#{Akashi.name}-#{name_suffix}-#{next_number(vpc: vpc)}"
          end

          def object_class
            @object_class ||= "Subnet"
          end
        end
      end
    end
  end
end
