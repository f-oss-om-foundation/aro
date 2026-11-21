# frozen_string_literal: true

=begin

  glyph.rb

  aro dom glyph menu item.

  by i2097i

=end

require_relative "./menu_item"

class Aro::Dom::Glyph < Aro::Dom::MenuItem
  # belongs_to :menu

  EXEC_METHODS = [
    :create_glyph!
  ]

  def self.create_glyph!(menu_item_uuid, action_data = {})
    create_glyph_menu_item = Aro::Dom::MenuItem.find_by(uuid: menu_item_uuid)

    raise "invalid menu_item_uuid! #{menu_item_uuid}" if create_glyph_menu_item.nil?

    Aro::P.say("#{self.name} is the base essence within open_system")

    options = [
      {name: :back, value: :back},
      {name: :objecticus, value: :objecticus},
      {name: :perspecticus, value: :perspecticus}
    ]

    selected_option = Aro::P.default_select(
      I18n.t("open_system.create_glyph_select"),
      options
    )

    return false if selected_option.kind_of?(Symbol) &&
      selected_option == :back

    selected_const = selected_option == :perspecticus ? Aro::Dom::Perspecticus : Aro::Dom::Objecticus

    new_name = Aro::Dom::Designer.get_new_value_from_user(
      "enter name for new #{selected_option}:"
    )

    i = create_glyph_menu_item.menu.generate_new_item(
      new_name,
      for_type: :system,
      open_system_class: selected_const.name
    )

    i.aro_file.write!(
      Aro::Dom::Store.build_exec_oss_om_params!(
        new_name,
        selected_const,
        "open!",
        [i.uuid],
        {}
      )
    )

    Aro::P.say("new #{self.name} '#{i.localized_name}' created successfully!")
    Aro::Dom::Ma_ain.navigate_to!(create_glyph_menu_item.menu)
  end
end
