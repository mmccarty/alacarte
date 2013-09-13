class DropModulePolymorphism < ActiveRecord::Migration
  def change
    # Guides
    ActiveRecord::Base.connection.execute <<-'EOS'
      UPDATE guides g
      SET resource_id = NULL
      FROM resources r
      WHERE g.resource_id = r.id AND
            (r.mod_type <> 'MiscellaneousResource' OR
             r.mod_id NOT IN (SELECT id FROM miscellaneous_resources));
    EOS

    ActiveRecord::Base.connection.execute <<-'EOS'
      UPDATE guides g
      SET resource_id = r.mod_id
      FROM resources r
      WHERE g.resource_id = r.id;
    EOS

    ActiveRecord::Base.connection.execute \
      'ALTER TABLE guides RENAME COLUMN resource_id TO node_id;'

    # Pages
    ActiveRecord::Base.connection.execute <<-'EOS'
      UPDATE pages p
      SET resource_id = NULL
      FROM resources r
      WHERE p.resource_id = r.id AND
            (r.mod_type <> 'MiscellaneousResource' OR
             r.mod_id NOT IN (SELECT id FROM miscellaneous_resources));
    EOS

    ActiveRecord::Base.connection.execute <<-'EOS'
      UPDATE pages p
      SET resource_id = r.mod_id
      FROM resources r
      WHERE p.resource_id = r.id;
    EOS

    ActiveRecord::Base.connection.execute \
      'ALTER TABLE pages RENAME COLUMN resource_id TO node_id;'

    # Users
    ActiveRecord::Base.connection.execute <<-'EOS'
      UPDATE users u
      SET resource_id = NULL
      FROM resources r
      WHERE u.resource_id = r.id AND
            (r.mod_type <> 'MiscellaneousResource' OR
             r.mod_id NOT IN (SELECT id FROM miscellaneous_resources));
    EOS

    ActiveRecord::Base.connection.execute <<-'EOS'
      UPDATE users u
      SET resource_id = r.mod_id
      FROM resources r
      WHERE u.resource_id = r.id;
    EOS

    ActiveRecord::Base.connection.execute \
      'ALTER TABLE users RENAME COLUMN resource_id TO node_id;'

    # Tab Resources
    ActiveRecord::Base.connection.execute <<-'EOS'
      DELETE FROM tab_resources t
      USING resources r
      WHERE t.resource_id = r.id AND
            (r.mod_type <> 'MiscellaneousResource' OR
             r.mod_id NOT IN (SELECT id FROM miscellaneous_resources));
    EOS

    ActiveRecord::Base.connection.execute <<-'EOS'
      UPDATE tab_resources t
      SET resource_id = r.mod_id
      FROM resources r
      WHERE t.resource_id = r.id AND
            r.mod_type = 'MiscellaneousResource';
    EOS

    ActiveRecord::Base.connection.execute \
      'ALTER TABLE tab_resources RENAME COLUMN resource_id TO node_id;'
    ActiveRecord::Base.connection.execute \
      'ALTER TABLE tab_resources RENAME TO tab_nodes;'
    ActiveRecord::Base.connection.execute \
      'ALTER SEQUENCE tab_resources_id_seq RENAME TO tab_nodes_id_seq;'

    # User Resources
    ActiveRecord::Base.connection.execute <<-'EOS'
      DELETE FROM resources_users u
      USING resources r
      WHERE u.resource_id = r.id AND
            (r.mod_type <> 'MiscellaneousResource' OR
             r.mod_id NOT IN (SELECT id FROM miscellaneous_resources));
    EOS

    ActiveRecord::Base.connection.execute <<-'EOS'
      UPDATE resources_users u
      SET resource_id = r.mod_id
      FROM resources r
      WHERE u.resource_id = r.id AND
            r.mod_type = 'MiscellaneousResource';
    EOS

    ActiveRecord::Base.connection.execute \
      'ALTER TABLE resources_users RENAME COLUMN resource_id TO node_id;'
    ActiveRecord::Base.connection.execute \
      'ALTER TABLE resources_users RENAME TO nodes_users;'

    # Nodes
    remove_column :miscellaneous_resources, :content_type

    ActiveRecord::Base.connection.execute \
      'ALTER TABLE miscellaneous_resources RENAME TO nodes;'
    ActiveRecord::Base.connection.execute \
      'ALTER SEQUENCE miscellaneous_resources_id_seq RENAME TO nodes_id_seq;'

    drop_table :resources

    # Locals
    remove_column :locals, :book_search
    remove_column :locals, :book_search_label
    remove_column :locals, :enable_search
    remove_column :locals, :g_results
    remove_column :locals, :g_search
    remove_column :locals, :guides
    remove_column :locals, :site_search
    remove_column :locals, :site_search_label
    remove_column :locals, :types
  end
end
