class RemoveTitleFromShares < ActiveRecord::Migration
  def change
    remove_column :shares, :title, :string
  end
end
