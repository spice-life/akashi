module Akashi
  class Rds
    class SubnetGroup
      class << self
        def create(subnets:)
          response = Akashi::Aws.rds.client.create_db_subnet_group(
            db_subnet_group_name:        Akashi.name,
            db_subnet_group_description: Akashi.name,
            subnet_ids:                  subnets.map(&:id)
          )
          id = response[:db_subnet_group_name]

          puts "Created a SubnetGroup (#{id})."
        end
      end
    end
  end
end
