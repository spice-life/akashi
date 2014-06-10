class Akashi
  class Vpc
    class Base < Akashi::Base
      def name=(new_value)
        @object.add_tag("Name", value: new_value)
      end

      class << self
        def all
          collection = Akashi::Aws.ec2.send(demodulize.underscore.pluralize)
          collection.map { |object| new(object.id) }
        end

        def base_class
          @base_class ||= :":AWS::EC2::#{demodulize}".constantize
        end
      end
    end
  end
end
