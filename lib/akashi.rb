require "active_support/core_ext"
require "hashie/mash"
require "akashi/aws"
require "akashi/base"
require "akashi/builder"
require "akashi/ec2"
require "akashi/elb"
require "akashi/rds"
require "akashi/vpc"
require "akashi/version"

module Akashi
  class << self
    attr_accessor :application, :environment
    attr_reader   :manifest

    def manifest=(new_value)
      @manifest = Hashie::Mash.new(new_value)
      unless @manifest.role.all? { |role_name, _| role_names.include?(role_name.intern) }
        fail "Unknown role exists"
      end
    end

    def build
      Akashi::Builder.new.build
    end

    def destroy
      fail "Not implemented"
    end

    def name(separator: "-")
      fail "Invalid configurations" unless (!!application && !!environment)
      application + separator + environment
    end

    def klass(service, object, role = nil)
      context = "Akashi::#{service.to_s.camelize}::#{object.to_s.camelize}"
      context << "::#{role.to_s.camelize}" if !!role
      context.constantize
    end

    def role_names
      @role_names ||= [
        :elb,
        :gateway,
        :rds,
        :web,
      ]
    end
  end
end
