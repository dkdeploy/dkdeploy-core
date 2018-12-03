module Dkdeploy
  module InteractionHandler
    # Interaction handler for mysql
    class MySql
      # Interaction handler for sending password to MySQL client
      # This InteractionHandler provides output of the error code if MySQL
      # answers with an error to the command.
      #
      # @attr [String] password The password to send to terminal
      def initialize(password)
        @password = password
        # these two are declared as instance variables because the on_data method is called multiple times
        @return_message = ''
        @mysql_error_seen = false
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
          @mysql_error_seen = true if data =~ /.*ERROR.*/i
          return raise 'Unexpected data from stream. Can not send password to undefined stream' unless @mysql_error_seen

          # combine the multiple lines from error message. The fact that the error message will be shown multiple times is simply ignored
          @return_message << data
          message = 'Error on executing MySQL command! Response (error code) is: '
          SSHKit.config.output.send(:error, "#{message}\n         #{@return_message}")
          raise 'InteractionHandler caught a MySQL error'
        end
      end
    end
  end
end
