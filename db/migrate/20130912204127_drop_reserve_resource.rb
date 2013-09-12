class DropReserveResource < ActiveRecord::Migration
  def change
    drop_table :course_widgets
    drop_table :reserve_resources
  end
end
