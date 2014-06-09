require "forwardable"

class Akashi
  class Vpc
    class Base
      extend Fowardable

      def_delegators :@object, :id

      def initialize(object)
        @object = object
      end

      class << self
        def all
          collection = Akashi::Aws.ec2.send(demodulize.underscore.pluralize)
          collection.map { |object| new(object.id) }
        end

        def where(conditions = {})
          all.select do |instance|
            conditions.all? { |k, v| instance.send(k.intern) == v }
          end
        end

        def find(id)
          instances = where(id: id)
          fail "#{id} does not exist" if instances.empty?
          instances.first
        end

        def find_by(conditions = {})
          instances = where(conditions)
          fail "#{id} does not exist" if instances.empty?
          instances.first
        end
      end
    end
  end
end
