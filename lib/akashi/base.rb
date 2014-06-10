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
