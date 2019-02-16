# To change this template, choose Tools | Templates
# and open the template in the editor.

class ChangeColumnStyle < ActiveRecord::Migration[4.2]
  def self.up
    change_column :banners, :style, :string, :default => "info", :null => false
  end

  def self.down
  end
end
