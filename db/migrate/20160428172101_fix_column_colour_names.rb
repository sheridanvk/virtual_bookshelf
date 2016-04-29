class FixColumnColourNames < ActiveRecord::Migration
  def change
    change_table :books do |t|
      t.rename :colour, :spine_colour
    end

    add_column :books, :font_colour, :string
  end
end
