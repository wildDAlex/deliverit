class AddAttachmentToShares < ActiveRecord::Migration
  def change
    add_column :shares, :attachment, :string
  end
end
