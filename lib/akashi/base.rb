require "forwardable"

module Akashi
  class Base
    extend Forwardable
    def_delegators :@object, :id

    private_class_method :new

    def initialize(id)
      @object = self.class.base_class.new(id)
    end

    class << self
      def all
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

      def object_class
        @object_class ||= self.to_s.demodulize
      end

      def collection
        Akashi::Aws.send(service_class.underscore).send(object_class.underscore.pluralize)
      end

      def base_class
        @base_class ||= "::AWS::#{service_class}::#{object_class}".constantize
      end
    end
  end
end
