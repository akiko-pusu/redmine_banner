class CreateBanners < ActiveRecord::Migration
  def self.up
    create_table :banners do |t|
      t.column :enabled, :boolean
      t.column :type, :string
      t.column :banner_description, :string
      t.column :use_timer, :boolean
      t.column :start_date, :datetime
      t.column :end_date, :datetime
      t.column :project_id, :integer, :null => false
      t.column :updated_on, :datetime
    end
  end

  def self.down
    drop_table :banners
  end
end
