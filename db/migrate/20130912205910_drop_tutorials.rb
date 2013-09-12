class DropTutorials < ActiveRecord::Migration
  def change
    drop_table :authorships
    drop_table :resourceables
    drop_table :tutorials
    drop_table :unitizations
    drop_table :units

    remove_column :locals, :tutorial_page_title if column_exists? :locals, :tutorial_page_title
  end
end
