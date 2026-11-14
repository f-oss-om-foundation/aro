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
        :create_chapter!
      ]

      # the uuid of a table_of_contents menu_item:
      # (Aro::Dom::MenuItem)
      # is used to identify one each of the following:
      #   Aro::Dom::Menu
      #   Aro::Dom::DataBase::Directory
      # it does so by creating a new data_base (.oss_om/data_bases/chapters)
      # and also generating a new directory within that data_base
      # with the folder name 'the uuid of a table_of_contents menu_item'
      #
      def self.create_chapter!(uuid)
        raise "invalid uuid" if uuid.nil? || uuid.empty? || !uuid.kind_of?(String)
        directory = chapters_data_base.data_base_directories.find_by(
          unix_path: uuid
        )
        raise "invalid directory!" if directory.nil?

        contents_menu = Aro::Dom::Menu.find_by(uuid: directory.uuid)
        raise "invalid contents_menu!" if contents_menu.nil?

        puts :todo_active_record_chapter
        Aro::Dom::Ma_ain.sane_backtrace!
      end

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
            table_of_contents_item.localized_name,
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
