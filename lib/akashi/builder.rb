module Akashi
  class Builder
    def build
      create_ssl_certificate
      create_vpc
      create_internet_gateway
      create_subnets
      create_security_groups
      create_key_pair
      create_ec2_instances
      create_subnet_group
      create_db_instance
      create_load_balancer
    end

    private

    def create_ssl_certificate
      @ssl_certificate = !!Akashi.manifest.elb.ssl_certificate.name ?
        Akashi::Elb::SslCertificate.find_by(name: Akashi.manifest.elb.ssl_certificate.name) :
        Akashi::Elb::SslCertificate.create
    end

    def create_vpc
      @vpc = Akashi::Vpc::Instance.create

      @route_table      = Akashi::Vpc::RouteTable.find_by(vpc_id: @vpc.id)
      @route_table.name = Akashi.name
    end

    def create_internet_gateway
      @internet_gateway = Akashi::Vpc::InternetGateway.create

      @vpc.attach_internet_gateway(@internet_gateway)
      @route_table.create_route(internet_gateway: @internet_gateway)
    end

    def create_subnets
      Akashi.manifest.role.each do |role_name, role|
        role.subnets.each do |subnet|
          subnets[role_name] << Akashi.klass(:vpc, :subnet, role_name).
                                  create(vpc: @vpc, availability_zone: subnet.availability_zone)
        end

        if !!role.internet_connection
          subnets[role_name].each { |subnet| subnet.route_table = @route_table }
        end
      end
    end

    def create_security_groups
      Akashi.manifest.role.each do |role_name, role|
        security_group[role_name] = Akashi.klass(:vpc, :security_group, role_name).create(vpc: @vpc)
      end
    end

    def create_key_pair
      Akashi::Ec2::KeyPair.create
    end

    def create_ec2_instances
      Akashi.manifest.role.each do |role_name, role|
        role.subnets.zip(subnets[role_name]).each do |subnet, _subnet|
          if !!subnet.instance
            ami = Akashi::Ec2::Ami.find(subnet.instance.ami_id)

            (subnet.instance.number_of_instances || 1).times do
              ec2_instances[role_name] << Akashi::Ec2::Instance.create(
                ami:            ami,
                instance_class: subnet.instance.instance_class,
                security_group: security_group[role_name],
                subnet:         _subnet,
              )
            end
          end
        end
      end

      ec2_instances[:gateway].each do |ec2_instance|
        eip = Akashi::Vpc::ElasticIp.create
        eip.associate(instance: ec2_instance)
      end
    end

    def create_subnet_group
      @subnet_group = Akashi::Rds::SubnetGroup.create(subnets: subnets[:rds])
    end

    def create_db_instance
      @db_instance = Akashi::Rds::DbInstance.create(security_group: security_group[:rds])
    end

    def create_load_balancer
      @load_balancer = Akashi::Elb::LoadBalancer.create(
        security_group:  security_group[:elb],
        subnets:         subnets[:elb],
        ssl_certificate: @ssl_certificate,
      )
      @load_balancer.register_instances(ec2_instances[:web])
    end

    def ec2_instances
      @ec2_instances ||= Hashie::Mash.new.tap do |_ec2_instances|
        Akashi.role_names.each { |role_name| _ec2_instances[role_name] = [] }
      end
    end

    def security_group
      @security_group ||= Hashie::Mash.new
    end

    def subnets
      @subnets ||= Hashie::Mash.new.tap do |_subnets|
        Akashi.role_names.each { |role_name| _subnets[role_name] = [] }
      end
    end
  end
end
