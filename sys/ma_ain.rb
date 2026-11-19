# frozen_string_literal: true

=begin

  ma_ain.rb

  aro dom ma_ain.

  by i2097i

=end

module Aro
  module Dom
    class Ma_ain < Aro::Mancy
      include Singleton

      # evolution planning
      #
      # Cor       (copy of Aro::Cor)
      # Engine
      # Designer
      # Git
      # Ssh
      # Block     (copy of Aro::Dom::DataBase)
      # Chain     (copy of Aro::Dom::Directory)
      # Node      (copy of Aro::Dom::File)
      # List      (copy of Aro::Dom::Menu)
      # ListItem  (copy of Aro::Dom::MenuItem)
      #
      #

      EXEC_METHODS = [
        :exec_library!,
        :exec_configuration!,
        :exec_quit!
      ]

      RUN_MODES = [
        :design,
        :run
      ]

      UNICODE_KEYS = {
        bang:     "\u0021",
        check:    "\u2713",
        close:    "\u2A2F",
        integral: "\u222B",
        secure:   "\u266F",
        unsecure: "\u266D",
        yinyang:  "\u262F",
      }

      attr_accessor :current_menu, :previous_menu
      attr_accessor :data_mutex, :store_mutex
      attr_accessor :stores
      # todo: unused currently. init instance with hashing algo stuff
      attr_accessor :valid_security
      attr_accessor :run_mode

      def reign!
        begin
          # default mode is :run
          self.run_mode = 1
          Aro::P.say("Aro::Dom::Oss_OpenMenu.install!")
          if Aro::Dom::Oss_OpenMenu.install!
            Aro::P.say("Aro::Dom::Oss_OpenMenu.boot!")
            Aro::Dom::Oss_OpenMenu.boot!
          else
            Aro::P.say("installation failed. exiting now...")
            exit
          end

          self.run_mode = !Aro::Cor.is_production? ? 0 : 1
          Aro::P.say("Aro::Dom::Designer.design")
          Aro::Dom::Designer.design
        rescue RuntimeError => e
          Aro::P.say("#{e.class}! #{e.inspect}")
          raise e
        end
      end

      def initialize
        self.data_mutex = Mutex.new
        self.store_mutex = Mutex.new

        @stores = {}
      end

      def self.sane_backtrace!
        return if Aro::Cor.is_production?

        backtrace = Thread.current.backtrace[Aro::Mancy::S..].reverse.map{|l|
          l.gsub("#{Reiquire.gem_dir}", "").gsub(Aro::Mancy.root_dir, "")
        }.last(Aro::Mancy::V).join("\n")

        if Aro::Cor.ivar(:VERBOSE).to_s == :true.to_s
          Aro::P.less(backtrace)
        else
          puts(backtrace)
        end
      end

      def self.init!
        root_dir_path = Aro::Cor.ivar(:OSS_OM_HOME)
        return false if root_dir_path.nil? || !Dir.exist?(root_dir_path)
        Aro::P.say("#{self.name} initializing in #{root_dir_path}")
        Aro::Mancy.init(root_dir_path)
      end

      def self.is_encrypted?
        Aro::Dom::Ssh.encryption_installed? &&
          !self.instance.valid_security.nil?
      end

      def self.domain
        self.instance.current_menu.nil? ? super : "#{Aro::Mancy.aro_mancy_name}#{Aro::Mancy::A}#{Aro::Dom::Ma_ain}"
      end

      def self.mini_hud_for(display_text = nil)
        cryption_text = UNICODE_KEYS[
          is_encrypted? ? :secure : :unsecure
        ] + UNICODE_KEYS[:bang]

        if is_encrypted?
          cryption_text = "#{UNICODE_KEYS[:secure]}#{UNICODE_KEYS[:bang]}"
        else
          cryption_text = "#{UNICODE_KEYS[:unsecure]}#{UNICODE_KEYS[:bang]}"
        end

        mode_text = Aro::Dom::Ma_ain::RUN_MODES[self.instance.run_mode]
        [
          "(#{cryption_text})[#{mode_text}: ",
          display_text
        ].join("")
      end

      def self.ps1_display(cls_name = nil)
        super(domain)
      end

      def self.navigate_to!(menu)

        raise "invalid menu!" if menu.nil? || !menu.kind_of?(Aro::Dom::Menu)
        raise "invalid directory for #{menu.inspect}!" if menu.directory.nil?
        data_base = menu.directory.data_base
        raise "invalid data_base!" if data_base.nil?

        self.open_menu(menu)
      end

      def self.open!(data_base = :ma_ain)
        Aro::P.say("Aro::Dom::DataBase.open_menu(#{data_base})")
        staged_menu = nil
        begin
          staged_menu = Aro::Dom::DataBase.open_menu(data_base)
        rescue StandardError => e
          raise "#{self.name} error opening data_base '#{data_base}'! #{e.inspect}"
        end

        if data_base.to_sym == :ma_ain && self.instance.valid_security.nil?
          self.instance.valid_security = staged_menu.uuid
        end

        self.open_menu(staged_menu)
      end

      def self.toggle_run_mode
        self.instance.run_mode = self.instance.run_mode == 0 ? 1 : 0
      end

      def self.running?
        Aro::Dom::Ma_ain::RUN_MODES[self.instance.run_mode] == :run
      end

      def self.get_current_options
        options = []

        options << {back: :back, value: :back} unless self.instance.current_menu.uuid == self.instance.valid_security

        # show open_menu if not running or Aro::Cor ivar is set to false
        hide_preference = Aro::Cor.ivar(:HIDE_F_OSS_OM_MENU).to_s == "true"

        Aro::D.say("self.running?: #{self.running?}")
        Aro::D.say("will show open_menu: #{hide_preference && !self.running?}")

        if !hide_preference || !self.running?
          options << {name: "#{UNICODE_KEYS[:integral]}(#{Aro::Mancy::ARO_DIRECTORY})", value: :open_menu}
        end

        options += self.instance.current_menu.menu_items.select{|mi| mi.user?}.map{|menu_item|
          {name: menu_item.localized_name, value: menu_item.uuid}
        }
        options += self.instance.current_menu.menu_items.select{|mi| mi.system?}.map{|menu_item|
          {name: menu_item.localized_name, value: menu_item.uuid}
        }

        options
      end

      def self.exec_library!
        Aro::Dom::Ma_ain.open!(:library)
      end

      def self.exec_configuration!
        Aro::Dom::Ma_ain.open!(:configuration)
      end

      def self.exec_quit!
        exit
      end

      def get_store_for(aro_file)
        raise "invalid aro_file!" if aro_file.nil?

        if @stores[aro_file.uuid].nil?
          new_store = Aro::Dom::Store.new
          new_store.open_file_path = aro_file.aro_file_path
          @stores[aro_file.uuid] = new_store
        end

        return Aro::Dom::Ma_ain.instance.stores[aro_file.uuid]
      end

      def self.run_plugin!(chapter_menu_item, action_data)
        plugin_file_path = action_data["plugin_file_path"]

        raise "invalid plugin_file_path! #{plugin_file_path}" if plugin_file_path.nil? ||
          !::File.exist?(plugin_file_path)

        new_action_data = action_data.dup

        data_callback = Proc.new{|d|
          if d.kind_of?(Hash)
            d["plugin_file_path"] = action_data["plugin_file_path"]
            d["oss_om_type"] = action_data["oss_om_type"]
            # self.instance.store_mutex.synchronize do
              chapter_menu_item.aro_file.write!({
                action_data: d
              })
            # end
          end
        }

        require action_data["plugin_file_path"]
        plugin_thread_action_data = action_data.dup
        plugin_const = nil
        begin
          plugin_const = "Aro::Dom::#{
            ::File.basename(
              action_data[:plugin_file_path.to_s]
            ).to_s.downcase.split(".")[
              Aro::Mancy::O
            ].split("_").map{|w| w.capitalize}.join("")
          }".constantize

          raise "must respond_to :oss_om_start!" unless plugin_const.respond_to?(:oss_om_start!)

          if plugin_const.respond_to?(:configure_plugin_callback)
            plugin_const.configure_plugin_callback(data_callback)
            data_callback.call(plugin_const.oss_om_start!(plugin_thread_action_data))
            new_action_data = nil
          else
            new_action_data = plugin_const.oss_om_start!(plugin_thread_action_data)
          end
        rescue StandardError => e
          Aro::P.say("plugin thread threw an error: #{e}")
          new_action_data = nil
        end

        data_callback.call(new_action_data) unless new_action_data.nil?
      end

      private

      def self.open_menu(menu)
        self.instance.current_menu = menu
      end
    end
  end
end