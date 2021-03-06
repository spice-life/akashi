module Akashi
  class Ec2
    class Base < Akashi::Base
      def name=(new_value)
        @object.add_tag("Name", value: new_value)
      end

      def name
        @object.tags["Name"]
      end

      class << self
        def service_class
          @service_class ||= "EC2"
        end
      end
    end
  end
end
