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

  def self.project_from(glyph)
    case glyph.class.name
    when Aro::Dom::Objecticus.name
      Aro::Dom::Ma_ain.sane_backtrace!
      puts "leverage FDot"
      Aro::P.less(glyph.inspect)
    when Aro::Dom::Perspecticus.name
      Aro::Dom::Ma_ain.sane_backtrace!
      puts "leverage FDot"
      Aro::P.less(glyph.inspect)
    end
  end

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
