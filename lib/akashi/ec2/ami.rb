module Akashi
  class Ec2
    class Ami < Akashi::Ec2::Base
      def_delegators :@object, :architecture, :name, :state, :type,
                               :root_device_name, :root_device_type

      class << self
        def object_class
          @object_class ||= "Image"
        end
      end
    end
  end
end
