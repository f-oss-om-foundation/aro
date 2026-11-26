# frozen_string_literal: true

=begin

  prompt.rb

  base logger for aro.

  by i2097i

=end

module Aro
  class Prompt
    include Singleton

    attr_accessor :prompt

    def initialize
      self.prompt = TTY::Prompt.new
    end

    def self.p
      Aro::Prompt.instance.prompt
    end

    def self.should_print?
      Aro::Cor::BOOLS[:TRUE]
    end

    def self.ask(message)
      FDot::Based.ask(message) {|new_value|
        return new_value
      }
    end

    def self.say(message)
      puts normalize_message(message)
    end

    def self.default_select(display_text, options)
      FDot::Based.tty_prompt_select(
        Aro::Dom::Ma_ain.mini_hud_for(display_text),
        options
      ) {|selected_option|
        return selected_option
      }
    end

    def self.less(message)
      FDot::Based.less(message)
    end

    def self.normalize_message(message)
      return message.join("\n") if message.kind_of?(Array)
      message
    end
  end
end
