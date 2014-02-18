class AddShowLinksToUsers < ActiveRecord::Migration
  def change
    add_column :users, :show_links, :boolean, default: true
  end
end
