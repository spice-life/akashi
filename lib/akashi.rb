require "openssl"
require "active_support/core_ext"
require "akashi/aws"

module Akashi
  class << self
    attr_accessor :application, :environment, :manifest

    def build
      vpc = Akashi::VPC.create

      internet_gateway = Akashi::VPC::InternetGateway.create
      vpc.internet_gateway = internet_gateway

      subnets = {}
      roles do |name, role|
        subnets[name] = []
        klass = Akashi::VPC::Subnet.const_get(name.camelize)
        role["subnets"].each do |subnet|
          subnets[name] << klass.create(availability_zone: subnet["availability_zone"])
        end
      end

      route_table = Akashi::VPC::RouteTable.where(vpc: vpc).first
      route_table.create_route(gateway: internet_gateway)
      roles do |name, role|
        if !!role["internet_connection"]
          subnets[name].each { |subnet| route_table.associate_subnet(subnet: subnet) }
        end
      end

      security_group = {}
      roles do |name, role|
        klass = Akashi::VPC::SecutiryGroup.const_get(name.camelize)
        security_group[name] = klass.create(vpc: vpc)
      end

      Akashi::RDS::SubnetGroup.create(subnets: subnets[:rds])
      Akashi::RDS.create(security_group: security_group[:rds])

      roles do |name, role|
        role["subnets"].each do |subnet|
          subnet["instances"].each { |instance| Akashi::EC2.create(instance) }
        end
      end

      ssl_certificate = Akashi::ELB::SSLCertificate.create
      Akashi::ELB.create(
        security_group:  security_group[:elb],
        subnet:          subnets[:elb],
        ssl_certificate: ssl_certificate,
      )
    end

    def destroy
      fail "Not implemented"
    end

    def name_tag
      "#{application}-#{environment}"
    end

    def file_base_name
      "#{application}_#{environment}"
    end

    def private_key
      unless !!@private_key
        private_key_path = manifest["elb"]["ssl_certificate"]["private_key_path"]
        @private_key = OpenSSL::PKey::RSA.new(File.read(private_key_path))
      end
      @private_key
    end

    def roles
      return manifest["role"] unless block_given?

      role_names.each do |name|
        yield name, manifest["role"][name.to_s]
      end
    end

    def role_names
      @role_names ||= [
        :elb,
        :ssh_gateway,
        :rds,
        :web_server,
      ]
    end
  end
end
