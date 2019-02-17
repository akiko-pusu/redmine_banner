class AddDisplayPartToBanners < ActiveRecord::Migration[4.2]
  def self.up
    add_column :banners, :display_part, :string, :default => "all", :null => false
  end

  def self.down
    remove_column :banners, :display_part
  end
end

