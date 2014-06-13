require "active_support/core_ext"
require "hashie/mash"
require "akashi/aws"
require "akashi/base"
require "akashi/ec2"
require "akashi/elb"
require "akashi/rds"
require "akashi/vpc"

module Akashi
  class << self
    attr_accessor :application, :environment
    attr_reader   :manifest

    def manifest=(new_value)
      @manifest = Hashie::Mash.new(new_value)
      unless @manifest.role.all? { |role_name, _| role_names.include?(role_name.intern) }
        fail "Unknown role exists"
      end
    end

    def build
      vpc = Akashi::Vpc::Instance.create

      route_table      = Akashi::Vpc::RouteTable.find_by(vpc_id: vpc.id)
      route_table.name = Akashi.name

      internet_gateway = Akashi::Vpc::InternetGateway.create
      vpc.attach_internet_gateway(internet_gateway)
      route_table.create_route(internet_gateway: internet_gateway)

      ssl_certificate = Akashi::Elb::SslCertificate.create

      Akashi::Ec2::KeyPair.create

      manifest.role.each do |role_name, role|
        subnets[role_name]   = []
        subnet_class         = klass(:vpc, :subnet, role_name)
        security_group_class = klass(:vpc, :security_group, role_name)

        security_group[role_name] = security_group_class.create(vpc: vpc)

        role.subnets.each do |subnet|
          _subnet = subnet_class.create(vpc: vpc, availability_zone: subnet.availability_zone)
          subnets[role_name] << _subnet

          if !!subnet.instance
            ami = Akashi::Ec2::Ami.find(subnet.instance.ami_id)

            (subnet.instance.number_of_instances || 1).times do
              Akashi::Ec2::Instance.create(
                ami:               ami,
                instance_class:    subnet.instance.instance_class,
                security_group:    security_group[role_name],
                subnet:            _subnet,
                allocated_storage: subnet.instance.allocated_storage,
              )
            end
          end
        end

        if !!role.internet_connection
          subnets[role_name].each { |subnet| subnet.route_table = route_table }
        end
      end

      Akashi::Rds::SubnetGroup.create(subnets: subnets[:rds])
      Akashi::Rds::DbInstance.create(security_group: security_group[:rds])

      Akashi::Elb::LoadBalancer.create(
        security_group:  security_group[:elb],
        subnets:         subnets[:elb],
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

    def klass(service, object, role = nil)
      context = "Akashi::#{service.to_s.camelize}::#{object.to_s.camelize}"
      context << "::#{role.to_s.camelize}" if !!role
      context.constantize
    end

    def subnets
      @subnets ||= Hashie::Mash.new
    end

    def security_group
      @security_group ||= Hashie::Mash.new
    end

    def role_names
      @role_names ||= [
        :elb,
        :gateway,
        :rds,
        :web,
      ]
    end
  end
end
