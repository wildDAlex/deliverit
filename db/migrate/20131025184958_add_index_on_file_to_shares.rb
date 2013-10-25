class AddIndexOnFileToShares < ActiveRecord::Migration
  def change
    add_index :shares, :file
  end
end

