require "openssl"
require "active_support/core_ext"
require "akashi/aws"

module Akashi
  class << self
    attr_accessor :application, :environment, :manifest

    def build
      vpc = Akashi::Vpc.create

      internet_gateway = Akashi::Vpc::InternetGateway.create
      vpc.internet_gateway = internet_gateway

      subnets = {}
      roles do |name, role|
        subnets[name] = []
        klass = "Akashi::Vpc::Subnet::#{name.camelize}".constantize
        role["subnets"].each do |subnet|
          subnets[name] << klass.create(
            vpc:               vpc,
            availability_zone: subnet["availability_zone"],
          )
        end
      end

      route_table      = Akashi::Vpc::RouteTable.find_by(vpc_id: vpc.id)
      route_table.name = Akashi.name
      route_table.create_route(internet_gateway: internet_gateway)
      roles do |name, role|
        if !!role["internet_connection"]
          subnets[name].each { |subnet| subnet.route_table = route_table }
        end
      end

      security_group = {}
      roles do |name, role|
        klass = "Akashi::Vpc::SecutiryGroup::#{name.camelize}".constantize
        security_group[name] = klass.create(vpc: vpc)
      end

      Akashi::Rds::SubnetGroup.create(subnets: subnets[:rds])
      Akashi::Rds.create(security_group: security_group[:rds])

      roles do |name, role|
        role["subnets"].each do |subnet|
          subnet["instances"].each { |instance| Akashi::Ec2.create(instance) }
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

    def name
      "#{application}-#{environment}"
    end

    def file_name
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
