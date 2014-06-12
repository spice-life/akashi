module Akashi
  class Elb
    class Base < Akashi::Base
      class << self
        def service_class
          @service_class ||= "ELB"
        end
      end
    end
  end
end
