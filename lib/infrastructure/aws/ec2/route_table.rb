class Infrastructure
  class AWS
    class EC2
      class RouteTable < Infrastructure::AWS::EC2::Base
        class << self
          def find_by_vpc(vpc)
            find_all_by_vpc.first
          end

          def find_all_by_vpc(vpc)
            route_tables = all.select { |route_table| route_table.vpc_id == vpc.id }
            fail "Object not found" if route_tables.blank?

            route_tables.map do |rt|
              new.tap { |obj| obj.id = route_table.id }
            end
          end

          def all
            @ec2.route_tables
          end
        end

        def create_route!(internet_gateway)
          @ec2.client.create_route(
            route_table_id:         id,
            destination_cidr_block: "0.0.0.0/0",
            gateway_id:             internet_gateway.id,
          )
        end

        def associate_with_subnet!(subnet)
          @ec2.client.associate_route_table(subnet_id: subnet.id, route_table_id: id)
        end

        def exists?
          @ec2.route_tables.any? { |route_table| route_table.id == id }
        end
      end
    end
  end
end
