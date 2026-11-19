# frozen_string_literal: true

=begin

  menu.rb

  aro dom menu.

  by i2097i

=end

class Aro::Dom::Menu < ActiveRecord::Base
  include Aro::Dom::Uuid

  self.inheritance_column = :open_system_class

  OPEN_SYSTEM_CLASSES = [
    "Aro::Dom::Cubicus",
    "Aro::Dom::Glyph",
    "Aro::Dom::Objecticus",
    "Aro::Dom::Perspecticus",
  ]

  has_many :menu_items, class_name: "Aro::Dom::MenuItem"

  def localized_name
    I18n.t(full_i18n_path)
  end

  def full_i18n_path
    "#{self.class.table_name}.#{uuid}"
  end

  def directory
    @directory ||= Aro::Dom::DataBase::Directory.find_by(uuid: uuid)
  end

  def generate_new_item(localized_name, for_type: :user, open_system_class: nil)
    localized_name = localized_name&.to_s
    new_menu_item = menu_items.create(type_flag: for_type)
    if !open_system_class.nil? &&
      Aro::Dom::Menu::OPEN_SYSTEM_CLASSES.include?(open_system_class&.to_s)
      new_menu_item.update(open_system_class: open_system_class)

      # load from constant
      new_menu_item = new_menu_item.open_system_class.constantize.find_by(uuid: new_menu_item.uuid)

    end
    Aro::Dom::DataBase.sync_menu_item!(new_menu_item, localized_name)
    new_menu_item
  end

  def rename_item(menu_item, new_name)
    raise "invalid menu item!" unless !menu_item.nil? &&
      self.menu_items.include?(menu_item)

    Aro::Dom::DataBase.sync_menu_item!(menu_item, new_name)
  end

  def generate_ma_ain!
    return unless is_menu_named?(:ma_ain) &&
      menu_items.empty?

    [:library, :open_system, :configuration, :quit].each{|k|
      i = generate_new_item(k, for_type: :system)

      if k == :open_system
        i.aro_file.write!(
          Aro::Dom::Store.build_exec_oss_om_params!(
            k,
            Aro::Dom::Oss_OpenSystem,
            "start!",
            [i.uuid],
            {}
          )
        )
      else
        i.aro_file.write!(
          Aro::Dom::Store.build_exec_oss_om_params!(
            k,
            Aro::Dom::Ma_ain,
            "exec_#{k}!"
          )
        )
      end
    }
  end

  def generate_configuration!
    return unless is_menu_named?(:configuration) &&
      menu_items.empty?

    [:cor, :git, :ssh].each{|k|
      i = generate_new_item(k, for_type: :system)

      i.aro_file.write!(
        Aro::Dom::Store.build_exec_oss_om_params!(
          k,
          Aro::Dom::Oss_OpenMenu,
          "open_#{k}!"
        )
      )
    }
  end

  def generate_user_default!
    return unless menu_items.empty?
    generate_new_item(I18n.t("open_menu.default_user_item_text", localized_name: localized_name))
  end

  private

  def is_menu_named?(name_sym)
    name_sym = name_sym&.to_sym

    !directory.nil? &&
      directory.unix_path.to_sym == name_sym
  end
end