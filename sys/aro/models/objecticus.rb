# frozen_string_literal: true

=begin

  objecticus.rb

  aro dom objecticus menu item.

  by i2097i

=end


class Aro::Dom::Objecticus < Aro::Dom::Glyph
  # belongs_to :menu

  EXEC_METHODS = [
    :open!
  ]

  def self.open!(objecticus_uuid, action_data = {})
    objecticus_menu_item = Aro::Dom::Objecticus.find_by(uuid: objecticus_uuid)
    raise "invalid objecticus_uuid #{objecticus_uuid}" if objecticus_menu_item.nil?

    Aro::Dom::Cubicus.project_from(objecticus_menu_item)
  end
end
