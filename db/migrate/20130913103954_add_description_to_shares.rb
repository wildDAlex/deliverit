class AddDescriptionToShares < ActiveRecord::Migration
  def change
    add_column :shares, :description, :string
  end
end
