# frozen_string_literal: true

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
        if data =~ /.*password.*/i
          channel.send_data("#{@password}\n")
        else
          channel.close
          raise 'Unexpected data from stream. Can not send password to undefined stream.'
        end
      end
    end
  end
end
