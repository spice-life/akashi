require "akashi/vpc/security_group/base"
require "akashi/vpc/security_group/elb"
require "akashi/vpc/security_group/rds"
require "akashi/vpc/security_group/ssh_gateway"
require "akashi/vpc/security_group/web_server"

module Akashi
  class Vpc
    class SecurityGroup < Akashi::Vpc::Base
      def_delegatros :@object, :description, :name, :vpc_id, :authorize_ingress
    end
  end
end
