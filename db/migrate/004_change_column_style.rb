# To change this template, choose Tools | Templates
# and open the template in the editor.

class ChangeColumnStyle < ActiveRecord::Migration
  def self.up
    change_column :banners, :style, :string, :default => "info", :null => false
  end

  def self.down
  end
end
