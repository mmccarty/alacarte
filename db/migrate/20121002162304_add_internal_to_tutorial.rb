class AddInternalToTutorial < ActiveRecord::Migration
  def self.up
    add_column :tutorials, :internal, :boolean
  end

  def self.down
    remove_column :tutorials, :internal
  end
end
