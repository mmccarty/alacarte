class DropBookResource < ActiveRecord::Migration
  def change
    drop_table :book_resources
    drop_table :books
  end
end
