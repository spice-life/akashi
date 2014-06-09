require "akashi/vpc/subnet/base"
require "akashi/vpc/subnet/elb"
require "akashi/vpc/subnet/rds"
require "akashi/vpc/subnet/ssh_gateway"
require "akashi/vpc/subnet/web_server"

module Akashi
  class VPC
    class Subnet < Akashi::VPC::Base
      def_delegators :@object, :vpc_id

      def cidr_block
        IPAddr.new(@object.cidr_block)
      end
    end
  end
end
