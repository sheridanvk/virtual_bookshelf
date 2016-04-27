class AddColourToBooks < ActiveRecord::Migration
  def change
    add_column :books, :colour, :string
  end
end
