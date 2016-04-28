class AddHeightToBooks < ActiveRecord::Migration
  def change
    add_column :books, :height, :integer
  end
end
