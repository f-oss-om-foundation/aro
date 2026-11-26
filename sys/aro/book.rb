# frozen_string_literal: true

=begin

  book.rb

  aro dom book.

  by i2097i

=end

module Aro
  module Dom
    class Book

      EXEC_METHODS = [
        :open_chapter!,
        :create_chapter!
      ]

      def self.open_chapter!(chapter_item_uuid = nil, action_data = {})
        chapter_menu_item = Aro::Dom::MenuItem.find_by(uuid: chapter_item_uuid)
        raise "invalid uuid! #{chapter_item_uuid}" if chapter_menu_item.nil?

        puts TTY::Font.new(:standard).write(
          chapter_menu_item.localized_name,
          letter_spacing: 1
        )

        raise "invalid action data for #{chapter_menu_item.inspect}!" if action_data.nil? ||
          !action_data.kind_of?(Hash)

        puts JSON.pretty_generate(action_data)

        unless action_data["oss_om_type"].nil?
          case action_data["oss_om_type"].to_sym
          when :key_value_store
            Aro::Dom::Designer.design_schema_for(chapter_menu_item)
          when :plugin
            Aro::P.less("Aro::Dom::Ma_ain.running? #{Aro::Dom::Ma_ain.running?}")
            if Aro::Dom::Ma_ain.running?
              Aro::Dom::Ma_ain.run_plugin!(chapter_menu_item, action_data)
            else
              Aro::Dom::Designer.design_plugin_for(chapter_menu_item)
            end
          end
        else
          Aro::Dom::Designer.design_schema_for(chapter_menu_item)
        end
      end

      #
      # the expected value here is explicitly the shared uuid of the
      #   Aro::Dom::Menu
      #   Aro::Dom::DataBase::Directory
      def self.create_chapter!(uuid)
        raise "invalid uuid" if uuid.nil? || uuid.empty? || !uuid.kind_of?(String)
        directory = chapters_data_base.data_base_directories.find_by(
          uuid: uuid
        )
        raise "invalid directory!" if directory.nil?

        contents_menu = Aro::Dom::Menu.find_by(uuid: directory.uuid)
        raise "invalid contents_menu!" if contents_menu.nil?

        chapter_params = {
          title: "chapter_#{contents_menu.menu_items.count}", # auto-increment
          text: nil
        }

        while chapter_params[:text].nil?
          chapter_params[:text] = Aro::Dom::Imports.get_plain_text_import(
            "import plain text from file for #{chapter_params[:title]}: (choose file)"
          )

          return if chapter_params[:text] == false
        end

        chapter_menu_item = contents_menu.generate_new_item(chapter_params[:title], for_type: :system)

        chapter_menu_item.aro_file.write!(
          Aro::Dom::Store.build_exec_oss_om_params!(
            chapter_params[:title],
            Aro::Dom::Book,
            "open_chapter!",
            [chapter_menu_item.uuid],
            chapter_params
          )
        )

        Aro::Dom::Ma_ain.navigate_to!(contents_menu)
      end

      # the table_of_contents menu_item:
      # (Aro::Dom::MenuItem)
      # a new directory is generated if needed
      #   Aro::Dom::DataBase::Directory
      # then a new menu is created if needed
      #   Aro::Dom::Menu
      # the menu and the directory share a uuid.
      # this creates new data_base folder (.oss_om/data_bases/chapters)
      # and also generates a new directory folder within the chapters data_base folder.
      # this folder's name is 'the uuid of a table_of_contents menu_item'
      #
      def self.open_table_of_contents!(table_of_contents_item)
        raise "invalid menu item! #{table_of_contents_item.inspect}" unless table_of_contents_item.kind_of?(Aro::Dom::MenuItem)

        # open_contents
        directory = chapters_data_base.data_base_directories.find_or_create_by(
          unix_path: table_of_contents_item.uuid
        )

        contents_menu = Aro::Dom::Menu.find_by(uuid: directory.uuid)
        if contents_menu.nil?
          # find or create the new contents_menu
          contents_menu = Aro::Dom::Menu.create(uuid: directory.uuid)
          Aro::Dom::Locale.add_i18n_key(
            table_of_contents_item.menu.localized_name,
            new_i18n_display_key: contents_menu.uuid
          )
          [:create_chapter].each{|k|
            i = contents_menu.generate_new_item(k, for_type: :system)

            i.aro_file.write!(
              Aro::Dom::Store.build_exec_oss_om_params!(
                k,
                Aro::Dom::Book,
                "#{k}!",
                [contents_menu.uuid]
              )
            )
          }
        end

        contents_menu
      end

      private

      def self.chapters_data_base
        Aro::Dom::DataBase.find_or_create_by(unix_path: :chapters)
      end

    end
  end
end
