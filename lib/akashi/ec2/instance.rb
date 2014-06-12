module Akashi
  class Ec2
    class Instance < Akashi::Ec2::Base
      def_delegators :@object, :public_dns_name, :public_ip_address,
                               :private_dns_name, :private_ip_address, :image_id,
                               :key_name, :subnet_id, :vpc_id, :status, :statub_code

      class << self
        def create(ami:, instance_class:, security_group:, subnet:, allocated_storage:, associate_public_ip_address: false)
          name = "#{subnet.name}-#{next_number(subnet: subnet)}"

          response = Akashi::Aws.ec2.instances.create(
            image_id:                    ami.id,
            key_name:                    Akashi.name,
            security_group_ids:          [ security_group.id ],
            subnet_id:                   subnet.id,
            instance_type:               instance_class,
            associate_public_ip_address: !!associate_public_ip_address,
            block_device_mappings:       [
              {
                device_name:  ami.root_device_name,
                ebs:          {
                  volume_size:           allocated_storage,
                  delete_on_termination: true,
                  volume_type:           "standard",
                },
              },
            ],
          )

          new(response.id).tap do |instance|
            instance.name = name
            puts "Created an EC2 Instance (#{instance.id}) on a Subnet (#{subnet.id})."
          end
        end

        def next_number(subnet:)
          "%03d" % (where(subnet_id: subnet.id).count + 1)
        end
      end
    end
  end
end
