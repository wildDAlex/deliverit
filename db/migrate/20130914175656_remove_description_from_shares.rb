class RemoveDescriptionFromShares < ActiveRecord::Migration
  def change
    remove_column :shares, :description, :string
  end
end
