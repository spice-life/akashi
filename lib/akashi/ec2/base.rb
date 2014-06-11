module Akashi
  class Ec2
    class Base < Akashi::Base
      class << self
        def service_class
          @service_class ||= "EC2"
        end
      end
    end
  end
end
