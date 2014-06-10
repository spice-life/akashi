module Akashi
  class Vpc
    class RouteTable < Akashi::Vpc::Base
      def vpc_id
        @object.vpc.id
      end

      def create_route(internet_gateway:)
        @object.create_route("0.0.0.0/0", internet_gateway: internet_gateway.id)
        puts "Created a route to an InternetGateway (#{internet_gateway.id}) to a VPC (#{id})."
      end
    end
  end
end
