require "openssl"
require "active_support/core_ext"
require "hashie/mash"
require "akashi/aws"
require "akashi/base"
require "akashi/rds"
require "akashi/vpc"

module Akashi
  class << self
    attr_accessor :application, :environment
    attr_reader   :manifest

    def manifest=(new_value)
      @manifest = Hashie::Mash.new(new_value)
      unless @manifest.role.all? { |role_name, role| role_names.include?(role_name.intern) }
        fail "Unknown role exists"
      end
    end

    def build
      vpc = Akashi::Vpc::Instance.create

      internet_gateway = Akashi::Vpc::InternetGateway.create
      vpc.internet_gateway = internet_gateway

      subnets = {}
      manifest.role.each do |role_name, role|
        subnets[role_name.intern] = []
        klass = "Akashi::Vpc::Subnet::#{role_name.camelize}".constantize
        role.subnets.each do |subnet|
          subnets[role_name.intern] << klass.create(vpc: vpc, availability_zone: subnet.availability_zone)
        end
      end

      route_table      = Akashi::Vpc::RouteTable.find_by(vpc_id: vpc.id)
      route_table.name = Akashi.name
      route_table.create_route(internet_gateway: internet_gateway)
      manifest.role.each do |role_name, role|
        if !!role.internet_connection
          subnets[role_name.intern].each { |subnet| subnet.route_table = route_table }
        end
      end

      security_group = {}
      manifest.role.each do |role_name, role|
        klass = "Akashi::Vpc::SecurityGroup::#{role_name.camelize}".constantize
        security_group[role_name.intern] = klass.create(vpc: vpc)
      end

      Akashi::Rds::SubnetGroup.create(subnets: subnets[:rds])
      Akashi::Rds::DbInstance.create(security_group: security_group[:rds])

      manifest.role.each do |role_name, role|
        role.subnets.each do |subnet|
          subnet.instances.each { |instance| Akashi::Ec2.create(instance) }
        end
      end

      ssl_certificate = Akashi::Elb::SslCertificate.create
      Akashi::Elb.create(
        security_group:  security_group[:elb],
        subnet:          subnets[:elb],
        ssl_certificate: ssl_certificate,
      )
    end

    def destroy
      fail "Not implemented"
    end

    def name(separator: "-")
      fail "Invalid configurations" unless (!!application && !!environment)
      application + separator + environment
    end

    def private_key
      unless !!@private_key
        private_key_path = manifest.elb.ssl_certificate.private_key_path
        @private_key = OpenSSL::PKey::RSA.new(File.read(private_key_path))
      end
      @private_key
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
