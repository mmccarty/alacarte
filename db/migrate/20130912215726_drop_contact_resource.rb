class DropContactResource < ActiveRecord::Migration
  def change
    drop_table :inst_resources
    drop_table :lib_resources
  end
end
