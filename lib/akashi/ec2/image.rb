module Akashi
  class Ec2
    class Image < Akashi::Ec2::Base
      def_delegators :@object, :architecture, :name, :state, :type,
                               :root_device_name, :root_device_type
    end
  end
end
