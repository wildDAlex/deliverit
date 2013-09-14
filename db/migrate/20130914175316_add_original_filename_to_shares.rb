class AddOriginalFilenameToShares < ActiveRecord::Migration
  def change
    add_column :shares, :original_filename, :string
  end
end
