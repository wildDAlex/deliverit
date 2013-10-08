class AddSizeToShares < ActiveRecord::Migration
  def change
    add_column :shares, :file_size, :integer
  end
end
