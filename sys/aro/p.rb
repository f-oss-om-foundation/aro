# frozen_string_literal: true

=begin
  
  p.rb

  p logger for aro space.

  by i2097i

=end

require_relative :"../shr/prompt".to_s

module Aro
  class P < Aro::Prompt

    def self.say(message)
      super("#{Aro::Dom::Ma_ain.ps1_display || Aro::Mancy.ps1_display}#{normalize_message(message)}")
    end
  end
end

