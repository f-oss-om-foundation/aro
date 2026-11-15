# frozen_string_literal: true

=begin

  plugins.rb

  aro dom plugins.

  by i2097i

=end

module Aro
  module Dom
    class Plugins

      def self.choose_plugin
        ensure_plugins_dir_exists!

        options = [
          {name: :back, value: :back}
        ] + Dir[::File.join(plugins_dir, "*")].map{|f|
          {name: ::File.basename(f), value: f}
        }

        selected_option = Aro::P.default_select(
          I18n.t("open_menu.plugins.select_plugin"),
          options
        )

        return false if selected_option.kind_of?(Symbol) &&
          selected_option == :back

        raise "invalid file path! #{selected_option}" unless File.exist?(selected_option)

        Aro::P.say("selected plugin: #{selected_option}")
        confirmed = Aro::P.p.ask(
          I18n.t(
            "open_menu.plugins.confirm_plugin",
            file_name: File.basename(selected_option)
          )
        )

        if :y.to_s != confirmed
          Aro::P.say(I18n.t("open_menu.plugins.user_cancelled"))
          return false
        end

        # todo: validate_plugin_here

        # ready to read plugin
        selected_option
      end

      def self.plugins_dir
        ::File.join(Aro::Cor.ivar(:OSS_OM_HOME), :plugins.to_s)
      end

      private

      def self.ensure_plugins_dir_exists!
        FileUtils.mkdir_p(plugins_dir) unless Dir.exist?(plugins_dir)
        ensure_plugin_default_files_exists!
      end

      def self.sample_plugin_raw
        [
          "# frozen_string_literal: true\n",
          "=begin\n",
          "  sample_plugin.rb\n",
          "  aro dom sample plugin\n",
          "  by #{`whoami`.strip}\n",
          "=end\n",
          "module Aro",
          "  module Dom",
          "    class SamplePlugin",
          "      def self.oss_om_start!(plugin_data = {})",
          "        puts self.name",
          "        puts __method__",
          "        puts \"running oss_om sample plugin...\"",
          "        plugin_data[\"sample_plugin_key\"] = \"hello_from_oss_om_plugin\"",
          "        plugin_data",
          "      end",
          "    end",
          "  end",
          "end",
          "\n",
        ].join("\n")
      end

      def self.ensure_plugin_default_files_exists!
        [
          [".keep", ""],
          ["sample_plugin.rb", sample_plugin_raw]
        ].each{|a|
          file_path = ::File.join(plugins_dir, a[Aro::Dom::Ma_ain::O])
          ::File.open(file_path, "w+") {|f|
            f.write(a[Aro::Dom::Ma_ain::S])
          } unless ::File.exist?(file_path)
        }
      end
    end
  end
end
