class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.string :title

      t.timestamps
    end
  end
end
