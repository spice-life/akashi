module Akashi
  class Vpc
    class RouteTable < Akashi::Vpc::Base
      def vpc_id
        @object.vpc.id
      end

      def create_route(internet_gateway:)
        @object.create_route(
          gateway_id:             internet_gateway.id,
          destination_cidr_block: "0.0.0.0/0",
        )
        puts "Created a route to an InternetGateway (#{internet_gateway.id}) to a VPC (#{id})."
      end
    end
  end
end
