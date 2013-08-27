class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute \
      "DROP INDEX IF EXISTS index_taggings_on_taggable_id_and_taggable_type;"

    change_table :taggings do |t|
      t.references :tagger, polymorphic: true
      t.string :context, limit: 120
      t.index [:taggable_id, :taggable_type, :context]
    end
  end
end
