# frozen_string_literal: true

=begin

  oss_open_system.rb

  aro dom oss_open_system.

  by i2097i

=end

module Aro
  module Dom
    class Oss_OpenSystem
      include Singleton

      attr_accessor :menu_item_uuid
      attr_accessor :runtime_data
      attr_accessor :access_validated
      attr_accessor :f_dot_mutex

      EXEC_METHODS = [
        :start!
      ]

      DEFAULT_RUNTIME = {
        f_dot_action_data: nil
      }

      def initialize
        self.menu_item_uuid = nil
        self.runtime_data = Aro::Dom::Oss_OpenSystem::DEFAULT_RUNTIME.dup.stringify_keys
        self.f_dot_mutex = Mutex.new
      end

      def self.start!(menu_item_uuid = nil, action_data = {})
        self.instance.access_validated = false
        self.instance.menu_item_uuid = menu_item_uuid
        menu_item = self.instance.get_menu_item

        raise "invalid menu_item! #{self.instance.menu_item_uuid}" if menu_item.nil?

        self.instance.runtime_data = action_data.dup

        puts TTY::Font.new(:standard).write(
          :open_system.to_s,
          letter_spacing: 1
        )

        raise "invalid action data for #{menu_item.inspect}!" if action_data.nil? ||
          !action_data.kind_of?(Hash)

        run_f_dot_authentication!

        Aro::P.say("#{self.name} f_dot access validated: #{self.instance.access_validated}")
        return unless self.instance.access_validated

        Aro::Dom::Ma_ain.open!(:open_system)
      end

      def write_runtime!
        get_menu_item.aro_file.write!({
          action_data: self.runtime_data
        })
      end

      def self.run_f_dot_authentication!
        write_state_callback = Proc.new{|incoming_data, validated = false|
          Aro::Dom::Oss_OpenSystem.instance.f_dot_mutex.synchronize do
            Aro::Dom::Oss_OpenSystem.instance.access_validated = true if validated
            Aro::Dom::Oss_OpenSystem.instance.update_runtime_f_dot(incoming_data)
          end
        }

        FDot::Based::Processor.initialize_with_data(
          Aro::Mancy.root_dir,
          write_state_callback,
          self.instance.runtime_data["f_dot_action_data"],
          true # one_move_mode
        )
      end

      def update_runtime_f_dot(action_data)
        if action_data.nil? ||
          !action_data.kind_of?(Hash)

          raise "invalid action data for #{action_data.inspect} in #{__method__}!"
        end

        self.runtime_data["f_dot_action_data"] = action_data

        self.write_runtime!
      end

      def get_menu_item
        Aro::Dom::MenuItem.find_by(uuid: self.menu_item_uuid)
      end

      def self.open_projector!(glyph)
        cubicus_menu = glyph.menu
        raise "invalid cubicus for glyph!: #{glyph}" if cubicus_menu.nil? ||
          !cubicus_menu.kind_of?(Aro::Dom::Cubicus)

        action_data = glyph.store.safe_get_key("action_data") || {}

        raise "invalid action data! #{action_data}" unless action_data.kind_of?(Hash)

        projector = Aro::Dom::Projector.new(cubicus_menu, glyph, action_data)
        projector.project!

        Aro::P.less(projector.inspect)
      end

    end
  end
end
