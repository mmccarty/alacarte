class DropUrlResource < ActiveRecord::Migration
  def change
    drop_table :links
    drop_table :url_resources
  end
end
