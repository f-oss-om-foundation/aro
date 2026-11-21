# frozen_string_literal: true

=begin

  projector.rb

  aro dom projector.

  by i2097i

=end

# this is a set of classes that run in-memory with data from:
#   the ma_ain open_system menu item's action_data (open_system_space)
#   the glyph's (is kind_of menu item) action_data (glyph_action_data)
#
#
module Aro
  module Dom
    class Projector

      DIRECTIONS = {
        north: 0,
        south: 1,
        east: 2,
        west: 3
      }

      DEFAULT_GLYPH = {
        "direction": 0,
        "position": {"x": 0, "y": 0, "z": 0}
      }

      DEFAULT_SPACE = []
      attr_accessor :is_projecting
      attr_accessor :cubicus_uuid
      attr_accessor :glyph_uuid
      attr_accessor :open_system_space
      attr_accessor :glyph_action_data

      # a projector generates and manages open_system space
      # a projector projects a glyph onto a display
      # a projector receives user input on behalf of the glyph
      # a projector modifies the attributes of a glyph in accordance with user input

      def initialize(cubicus, glyph, glyph_action_data)
        self.is_projecting = false
        self.cubicus_uuid = cubicus.uuid
        self.glyph_uuid = glyph.uuid

        self.glyph_action_data = glyph_action_data.empty? ? Aro::Dom::Projector::DEFAULT_GLYPH : glyph_action_data

        # get open_system_data
        open_system_item = Aro::Dom::Oss_OpenSystem.instance.get_menu_item
        open_system_data = open_system_item.store.safe_get_key("action_data") || {}
        raise "missing action data for #{open_system_item}!" if open_system_data.nil? ||
          !open_system_data.kind_of?(Hash)

        # load projector with open_system_space
        self.open_system_space = open_system_data["open_system_space"] || Aro::Dom::Projector::DEFAULT_SPACE
      end

      def project!
        self.is_projecting = true
        FDot::Based::Cubicus.launch!(self)
        self.is_projecting = false
      end

      def glyph
        Aro::Dom::Glyph.find_by(uuid: self.glyph_uuid)
      end

      def direction_name
        Aro::Dom::Projector::DIRECTIONS.select{|k, v| v == self.glyph_action_data["direction"]}.first[0]
      end

      # FDot::Based::Cubicus delegate
      def current_display
        (TTY::Font.new(:standard).write(
          glyph.localized_name,
          letter_spacing: 1
        ).split("\n") + [
          "the glyph is facing #{direction_name}.",
          "the glyph's position is #{self.glyph_action_data["position"]}.",
        ]).join("\n")
      end

      # FDot::Based::Cubicus delegate
      def current_controls
        [] # empty controls asserts keyboard movement in cubicus
      end

      # FDot::Based::Cubicus delegate
      def respond_to_control(keyboard_event)
        Aro::P.say("received #{keyboard_event} in #{__method__}")
      end

    end

  end
end