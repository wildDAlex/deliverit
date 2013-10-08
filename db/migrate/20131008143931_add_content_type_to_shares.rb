class AddContentTypeToShares < ActiveRecord::Migration
  def change
    add_column :shares, :content_type, :string
  end
end
