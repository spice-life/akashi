module Akashi
  class Rds
    class DbInstance < Akashi::Rds::Base
      def_delegators :@object, :db_instance_status, :db_name, :endpoint, :endpoint_port,
                               :engine, :engine_version, :vpc_id

      class << self
        def create(security_group:)
          password = Akashi.manifest.rds.password || random_password(10)
          options  = {
            db_name:                    Akashi.name(separator: "_"),
            db_instance_identifier:     Akashi.name,
            allocated_storage:          Akashi.manifest.rds.allocated_storage,
            db_instance_class:          Akashi.manifest.rds.instance_class,
            engine:                     "mysql",
            master_username:            Akashi.application,
            master_user_password:       password,
            multi_az:                   !!Akashi.manifest.rds.multi_az,
            availability_zone:          Akashi.manifest.rds.availability_zone,
            vpc_security_group_ids:     [ security_group.id ],
            db_subnet_group_name:       Akashi.name,
            engine_version:             Akashi.manifest.rds.engine_version,
            auto_minor_version_upgrade: true,
            publicly_accessible:        false,
          }
          if !!Akashi.manifest.rds.parameter_group_name
            options.merge!(db_parameter_group_name: Akashi.manifest.rds.parameter_group_name)
          end

          response = Akashi::Aws.rds.client.create_db_instance(options)

          new(response[:db_instance_identifier]).tap do |instance|
            puts "Created a RDS (#{instance.id}). Password is \"#{password}\"."
          end
        end

        def random_password(length)
          [*0..9, *"a".."z", *"A".."Z"].sample(length).join
        end

        def object_class
          @object_class ||= "DBInstance"
        end
      end
    end
  end
end
