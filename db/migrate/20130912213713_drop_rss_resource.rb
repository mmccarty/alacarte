class DropRssResource < ActiveRecord::Migration
  def change
    drop_table :feeds
    drop_table :rss_resources
  end
end
