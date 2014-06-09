module Akashi
  class VPC
    class InternetGateway < Akashi::VPC::Base
      def attach(vpc)
        @object.attach(vpc.id)
      end

      class << self
        def create
          response = Akashi::AWS.ec2.client.create_internet_gateway
          new(find(response[:internet_gateway][:internet_gateway_id]))
        end
      end
    end
  end
end
