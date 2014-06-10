module Akashi
  class Vpc
    class Base < Akashi::Base
      def name=(new_value)
        @object.add_tag("Name", value: new_value)
      end

      class << self
        def service_class
          @service_class ||= "EC2"
        end
      end
    end
  end
end
