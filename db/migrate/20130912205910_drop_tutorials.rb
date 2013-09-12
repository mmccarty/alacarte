class DropTutorials < ActiveRecord::Migration
  def change
    drop_table :authorships
    drop_table :resourceables
    drop_table :tutorials
    drop_table :unitizations
    drop_table :units
  end
end
