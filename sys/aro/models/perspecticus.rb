# frozen_string_literal: true

=begin

  perspecticus.rb

  aro dom perspecticus menu item.

  by i2097i

=end


class Aro::Dom::Perspecticus < Aro::Dom::Glyph
  # belongs_to :menu

  EXEC_METHODS = [
    :open!
  ]

  def self.open!(perspecticus_uuid, action_data = {})
    perspecticus_menu_item = Aro::Dom::Perspecticus.find_by(uuid: perspecticus_uuid)
    raise "invalid perspecticus_uuid #{perspecticus_uuid}" if perspecticus_menu_item.nil?

    Aro::Dom::Cubicus.project_from(perspecticus_menu_item)
  end
end
