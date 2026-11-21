# frozen_string_literal: true

=begin

  cubicus.rb

  aro dom cubicus menu.

  by i2097i

=end

require_relative "./menu"

class Aro::Dom::Cubicus < Aro::Dom::Menu

  EXEC_METHODS = [
    # ...
  ]

  def generate_open_system!
    return unless is_menu_named?(:open_system) &&
      menu_items.empty?

    [:create_glyph].each{|k|
      i = generate_new_item(k, for_type: :system)

      i.aro_file.write!(
        Aro::Dom::Store.build_exec_oss_om_params!(
          k,
          Aro::Dom::Glyph,
          "#{k}!",
          [i.uuid],
          {}
        )
      )
    }
  end
end
