# frozen_string_literal: true

class CreateMenus < ActiveRecord::Migration[8.1]
  def change
    create_table :menus do |t|
      t.string :uuid, null: false
      t.string :open_system_class, default: "Aro::Dom::Cubicus"

      t.timestamps
    end

    add_index :menus, :uuid, unique: true
  end
end
