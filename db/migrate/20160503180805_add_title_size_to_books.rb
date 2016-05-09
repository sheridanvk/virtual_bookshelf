class AddTitleSizeToBooks < ActiveRecord::Migration
  def change
    add_column :books, :title_size, :string, :default => "30px"
  end
end
