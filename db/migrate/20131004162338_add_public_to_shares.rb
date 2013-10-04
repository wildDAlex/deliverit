class AddPublicToShares < ActiveRecord::Migration
  def change
    add_column :shares, :public, :boolean, default: false
  end
end
