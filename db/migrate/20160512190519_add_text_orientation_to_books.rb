class AddTextOrientationToBooks < ActiveRecord::Migration
  def change
    add_column :books, :text_orientation, :string
  end
end
