module Akashi
  class Vpc
    class RouteTable < Akashi::Vpc::Base
      def create_route(gateway:)
        @object.create_route(
          gateway_id:             gateway.id,
          destination_cidr_block: "0.0.0.0/0",
        )
      end
    end
  end
end
