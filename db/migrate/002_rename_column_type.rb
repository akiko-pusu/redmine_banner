class RenameColumnType < ActiveRecord::Migration[4.2]
  def self.up
    # Not to use "type". It causes problem, "Can't mass-assign these protected attributes: type"
    rename_column :banners, :type, :style
  end

  def self.down
    rename_column :banners, :style, :type
  end
end
