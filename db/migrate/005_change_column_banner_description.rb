# #44: Changed banner description to text for advanced integration of images, etc
class ChangeColumnBannerDescription < ActiveRecord::Migration
  def self.up
    change_column :banners, :banner_description, :text
  end

  def down
     change_column :banners, :banner_description, :string
  end
end
