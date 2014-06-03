require "singleton"
require "yaml"
require "aws-sdk"
require_relative "ec2"

class Akashi
  class AWS
    include Singleton

    def initialize
      load_config
    end

    def ec2
      @ec2 ||= ::AWS::EC2.new
    end

    private

    def load_config
      ::AWS.config(YAML.load_file(config_path))
    end

    def config_path
      File.expand_path("../../config/aws.yml", __dir__)
    end
  end
end
