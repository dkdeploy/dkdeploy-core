# frozen_string_literal: true

require 'highline'

module Dkdeploy
  module Helpers
    # common helpers, which are not task specific
    module Common
      def terminal
        @terminal ||= HighLine.new
      end

      def ask_via_terminal(question_selector, &block)
        question = I18n.t(question_selector, scope: :dkdeploy)
        answer = terminal.ask(question, &block)
        String.new(answer)
      end

      def ask_variable(args, variable_name_symbol, question_selector, &block)
        ENV[variable_name_symbol.to_s.upcase] || args[variable_name_symbol] ||
          fetch(variable_name_symbol) || ask_via_terminal(question_selector, &block)
      end

      def ask_array_variable(args, variable_name_symbol, question_selector, &block)
        variable_content = ask_variable(args, variable_name_symbol, question_selector, &block)
        return variable_content if variable_content.is_a?(Array)
        return variable_content.split if variable_content.is_a?(String)

        raise(I18n.t('errors.variable_content_is_neither_string_nor_array', variable_name: variable_name_symbol, scope: :dkdeploy))
      end
    end
  end
end
