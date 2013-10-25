class AddDownloadCountToShares < ActiveRecord::Migration
  def change
    add_column :shares, :download_count, :integer, default: 0
  end
end
