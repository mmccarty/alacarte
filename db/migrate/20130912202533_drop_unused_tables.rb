class DropUnusedTables < ActiveRecord::Migration
  def change
    drop_table :comments
    drop_table :comment_resources

    drop_table :images
    drop_table :image_resources

    drop_table :lf_targets
    drop_table :libfind_resources

    drop_table :videos
    drop_table :video_resources
  end
end
