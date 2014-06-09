module Akashi
  class Vpc
    class SecurityGroup < Akashi::Vpc::Base
      def_delegators :@object, :description, :name, :vpc_id
    end
  end
end
