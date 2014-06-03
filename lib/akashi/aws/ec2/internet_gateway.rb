class Akashi
  class AWS
    class EC2
      class InternetGateway < Akashi::AWS::EC2::Base
        def create!
          response = @ec2.client.create_internet_gateway
          id = response[:internet_gateway][:internet_gateway_id]
        end

        def attach!(vpc)
          @ec2.client.attach_internet_gateway(vpc_id: vpc.id, internet_gateway_id: id)
        end

        def exists?
          @ec2.internet_gateways.any? { |internet_gateway| internet_gateway.id == id }
        end
      end
    end
  end
end
