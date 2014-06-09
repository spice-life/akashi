module Akashi
  class Vpc
    class SecurityGroup < Akashi::Vpc::Base
      def_delegators :@object, :description, :name, :vpc_id, :authorize_ingress
    end
  end
end
