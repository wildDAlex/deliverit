class AddFileToShares < ActiveRecord::Migration
  def change
    add_column :shares, :file, :string
  end
end
