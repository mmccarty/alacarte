class DropUploaderResource < ActiveRecord::Migration
  def change
    drop_table :image_managers
    drop_table :uploadables
    drop_table :uploader_resources

    remove_column :locals, :tutorial_page_title if column_exists? :locals, :tutorial_page_title
  end
end
