class DropDatabaseResource < ActiveRecord::Migration
  def change
    drop_table :database_dods
    drop_table :database_resources
  end
end
