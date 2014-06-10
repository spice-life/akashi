module Akashi
  class Rds
    class Base < Akashi::Base
      class << self
        def service_class
          @service_class ||= "RDS"
        end
      end
    end
  end
end
