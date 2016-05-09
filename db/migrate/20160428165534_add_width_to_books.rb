class AddWidthToBooks < ActiveRecord::Migration
  def change
    add_column :books, :width, :integer
  end
end
