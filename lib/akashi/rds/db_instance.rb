module Akashi
  class Rds
    class DbInstance < Akashi::Rds::Base
      def_delegators :@object, :db_instance_status, :db_name, :endpoint, :endpoint_port,
                               :engine, :engine_version, :vpc_id

      class << self
        def create(security_group:)
          password = random_password(10)

          response = Akashi::Aws.rds.client.create_db_instance(
            db_name:                    Akashi.name,
            db_instance_identifier:     Akashi.name,
            allocated_storage:          Akashi.manifest.rds.allocated_storage,
            db_instance_class:          Akashi.manifest.rds.instance_class,
            engine:                     "mysql",
            master_username:            Akashi.application,
            master_user_password:       password,
            multi_az:                   !!Akashi.manifest.rds.multi_az,
            availability_zone:          Akashi.manifest.rds.availability_zone,
            db_subnet_group_nmae:       Akashi.name,
            engine_version:             Akashi.manifest.rds.engine_version,
            auto_minor_version_upgrade: true,
            publicly_accessible:        false,
            vpc_security_group_ids:     [ security_group.id ],
          )
          id = response[:db_instance_identifier]

          puts "Created a RDS (#{id}). Password is \"#{password}\"."
        end

        def random_password(length)
          [*0..9, *"a".."z", *"A".."Z"].sample(length).join
        end

        def base_class
          @base_class ||= ::AWS::RDS::DBInstance
        end
      end
    end
  end
end
