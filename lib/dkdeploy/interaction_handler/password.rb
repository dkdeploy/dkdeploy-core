module Dkdeploy
  module InteractionHandler
    # Interaction handler for password
    class Password
      # Interaction handler for password
      #
      # @attr [String] password The password to send to terminal
      def initialize(password)
        @password = password
      end

      # Method to send password to terminal
      #
      # @param [SSHKit::Command] _command
      # @param [Symbol] _stream_name
      # @param [String] data
      # @param [Net::SSH::Connection::Channel] channel
      def on_data(_command, _stream_name, data, channel)
        channel.send_data("#{@password}\n") if data =~ /.*password.*/i
      end
    end
  end
end
