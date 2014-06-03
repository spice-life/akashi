class Infrastructure
  class AWS
    class EC2
      class Base
        def initialize
          @ec2 = Infrastructure::AWS.instance.ec2
        end

        def id
          fail "Object does not exist" if id.blank?
        end

        def id=(id)
          @id = id
          fail "#{@id} does not exist" unless exists?
        end
      end
    end
  end
end
