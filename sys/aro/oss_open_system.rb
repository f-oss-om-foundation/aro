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
      attr_accessor :runtime_mutex

      EXEC_METHODS = [
        :start!
      ]

      DEFAULT_RUNTIME = {
        f_dot_action_data: nil
      }

      def initialize
        self.menu_item_uuid = nil
        self.runtime_data = Aro::Dom::Oss_OpenSystem::DEFAULT_RUNTIME.dup.stringify_keys
        self.runtime_mutex = Mutex.new
      end

      def self.start!(menu_item_uuid = nil, action_data = {})
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

        self.instance.runtime_mutex.synchronize do
          run_f_dot_authentication!
        end

        Aro::Dom::Ma_ain.open!(:open_system)
      end

      def write_runtime!
        get_menu_item.aro_file.write!({
          action_data: self.runtime_data
        })
      end

      def self.run_f_dot_authentication!
        write_state_callback = Proc.new{|incoming_data|
          self.instance.update_runtime_f_dot(incoming_data)
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

    end
  end
end
