class Instance
  INSTANCE_ID = "i-06166d9bef1a08ae0"
  MINECRAFT_PORT = "25565"

  def self.start
    new.start
  end

  def self.stop
    new.stop
  end

  def self.backup
  end

  def initialize
    client = Aws::EC2::Resource.new
    @instance = client.instance(INSTANCE_ID)
    unless @instance.exists?
      raise "Do not exists instance: #{INSTANCE_ID}"
    end
  end

  def start
    case @instance.state.code
      when 16 # started
        ip_address = @instance.network_interfaces.first.data.association&.public_ip
        ":hammer_and_pick: Instance(#{INSTANCE_ID}) is already started. IP Address is `#{ip_address}:#{MINECRAFT_PORT}`"
      when 48 # terminated
        ":no_good_woman: Instance#{INSTANCE_ID} is terminated, so you cannot start it"
      else
        @instance.start

        count = 0
        while true do
          if count > 29
            raise "Error"
          else
            @instance.reload
            ip_address = @instance.network_interfaces.first.data.association&.public_ip
            count += 1
            sleep 1
          end
          unless ip_address.nil?
            break
          end
        end
        ":hammer_and_pick: Created Instance(#{INSTANCE_ID}). IP Address:\n `#{ip_address}:#{MINECRAFT_PORT}`"
    end
  end

  def stop
    case @instance.state.code
      when 48
        ":hammer_and_pick: Instance(#{INSTANCE_ID}) is terminated, so you cannot stop it"
      when 64
        ":hammer_and_pick: Instance(#{INSTANCE_ID}) is stopping, so will be stopped in a bit"
      when 80
        ":hammer_and_pick: Instance(#{INSTANCE_ID}) is already stopped"
      else
        @instance.stop

        count = 0
        while true do
          if @instance.state.code == 80 || @instance.state.code == 48
            break
          else
            if count > 25
              raise "Error" # TODO
            else
              count += 1
              sleep 1
            end
          end
          @instance.reload
        end
        ":hammer_and_pick: Instance(#{INSTANCE_ID}) has been stopped."
    end
  end
end
