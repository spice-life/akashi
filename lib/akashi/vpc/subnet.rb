require "akashi/vpc/subnet/base"
require "akashi/vpc/subnet/elb"
require "akashi/vpc/subnet/rds"
require "akashi/vpc/subnet/ssh_gateway"
require "akashi/vpc/subnet/web_server"

module Akashi
  class Vpc
    class Subnet < Akashi::Vpc::Base
      def cidr_block
        IPAddr.new(@object.cidr_block)
      end

      def route_table=(route_table)
        @object.route_table = route_table.id
        puts "A VPC (#{id}) associated with a RouteTable (#{route_table.id})."
      end

      class << self
        def attributes
          @attributes ||= [
            :availability_zone_name,
            :available_ip_address_count,
            :state,
            :vpc_id,
          ]
        end
      end
    end
  end
end
