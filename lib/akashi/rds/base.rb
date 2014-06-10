module Akashi
  class Rds
    class Base < Akashi::Base
      class << self
        def all
          collection = Akashi::Aws.rds.send(demodulize.underscore.pluralize)
          collection.map { |object| new(object.id) }
        end

        def base_class
          @base_class ||= "::AWS::RDS::#{demodulize}".constantize
        end
      end
    end
  end
end
