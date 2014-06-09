module Akashi
  class Vpc
    class InternetGateway < Akashi::Vpc::Base
      def attach(vpc)
        @object.attach(vpc.id)
      end

      class << self
        def create
          response = Akashi::Aws.ec2.client.create_internet_gateway
          new(find(response[:internet_gateway][:internet_gateway_id]))
        end
      end
    end
  end
end
