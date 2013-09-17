class DerivePagesFromGuides < ActiveRecord::Migration
  def change
    rename_column :pages, :page_description, :description
  end
end
