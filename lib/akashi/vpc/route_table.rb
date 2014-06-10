module Akashi
  class Vpc
    class RouteTable < Akashi::Vpc::Base
      def create_route(internet_gateway:)
        @object.create_route(
          gateway_id:             internet_gateway.id,
          destination_cidr_block: "0.0.0.0/0",
        )
        puts "Created route to #{internet_gateway.id} to #{id}"
      end
    end
  end
end
