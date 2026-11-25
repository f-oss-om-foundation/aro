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
      gets message
    end

    def self.say(message)
      puts normalize_message(message)
      # color = [
      #   :red,
      #   :green,
      #   :yellow,
      #   :blue,
      #   :magenta,
      #   :cyan,
      #   :white,
      #   :bright_red,
      #   :bright_green,
      #   :bright_yellow,
      #   :bright_blue,
      #   :bright_magenta,
      #   :bright_cyan,
      #   :bright_white
      # ].shuffle.shuffle.sample
      # p.say(
      #   normalize_message(message),
      #   color: color
      # )
    end

    def self.default_select(display_text, options)
      FDot::Based.tty_prompt_select(
        Aro::Dom::Ma_ain.mini_hud_for(display_text),
        options
      ) {|selected_option|
        return selected_option
      }
      # Aro::P.p.select(
      #   Aro::Dom::Ma_ain.mini_hud_for(display_text),
      #   options,
      #   show_help: :always,
      #   cycle: true,
      #   per_page: 11
      # )
    end

    def self.less(message)
      FDot::Based.less(message)
      # IO.popen("less -X", "w") { |f| f.puts(message) }
    end

    def self.normalize_message(message)
      return message.join("\n") if message.kind_of?(Array)
      message
    end
  end
end
