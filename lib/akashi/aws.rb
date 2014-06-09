require "aws-sdk"

module Akashi
  module Aws
    module_function

    def config=(new_value)
      ::AWS.config(new_value)
      services.each { |service| instance_variable_set(:"@#{service}", nil) }
    end

    def ec2
      @ec2 ||= ::AWS::EC2.new
    end

    def elb
      @elb ||= ::AWS::ELB.new
    end

    def iam
      @iam ||= ::AWS::IAM.new
    end

    def rds
      @rds ||= ::AWS::RDS.new
    end

    def services
      @services ||= [
        :ec2,
        :elb,
        :iam,
        :rds,
      ]
    end
  end
end
