class InitialSchema < ActiveRecord::Migration
  create_table "assign_resources", :force => true do |t|
    t.column "module_title",   :string,   :limit => 55
    t.column "label",          :string
    t.column "description",    :text
    t.column "assignment_url", :string
    t.column "syllabus_url",   :string
    t.column "global",         :integer,  :limit => 4,  :default => 0
    t.column "created_by",     :string
    t.column "updated_at",     :datetime
    t.column "content_type",   :string,                 :default => "Course Assignment"
  end

  create_table "comment_resources", :force => true do |t|
    t.column "module_title",  :string,                :default => "Comments", :null => false
    t.column "label",         :string
    t.column "topic",         :text
    t.column "num_displayed", :integer,               :default => 3,          :null => false
    t.column "updated_at",    :datetime
    t.column "content_type",  :string,                :default => "Comments"
    t.column "global",        :integer,  :limit => 4, :default => 0
    t.column "created_by",    :string
  end

  create_table "comments", :force => true do |t|
    t.column "comment_resource_id", :integer,                           :null => false
    t.column "author_name",         :string,   :default => "Anonymous", :null => false
    t.column "author_email",        :string
    t.column "body",                :text,     :default => "",          :null => false
    t.column "created_at",          :datetime,                          :null => false
  end

  add_index "comments", ["author_email", "created_at"], :name => "author_email"

  create_table "course_widgets", :force => true do |t|
    t.column "module_title", :string,                :default => "Course Tools",  :null => false
    t.column "label",        :string
    t.column "widget",       :text
    t.column "information",  :text
    t.column "updated_at",   :datetime
    t.column "content_type", :string,                :default => "Course Widget"
    t.column "global",       :integer,  :limit => 4, :default => 0
    t.column "created_by",   :string
  end

  create_table "database_dods", :force => true do |t|
    t.column "database_resource_id", :integer
    t.column "dod_id",               :integer
    t.column "description",          :text
    t.column "location",             :integer
  end

  add_index "database_dods", ["database_resource_id", "dod_id"], :name => "database_resource_id"

  create_table "database_resources", :force => true do |t|
    t.column "created_by",   :string
    t.column "updated_at",   :datetime
    t.column "module_title", :string,   :limit => 55, :default => "Databases", :null => false
    t.column "global",       :integer,  :limit => 4,  :default => 0
    t.column "content_type", :string,   :limit => 55, :default => "Databases", :null => false
    t.column "label",        :string
    t.column "info",         :text
  end

  create_table "dods", :force => true do |t|
    t.column "visible",     :integer, :limit => 3,   :default => 1
    t.column "title",       :string,  :limit => 191
    t.column "url",         :string
    t.column "startdate",   :string,  :limit => 20
    t.column "enddate",     :string,  :limit => 150
    t.column "provider",    :string,  :limit => 64,  :default => "", :null => false
    t.column "providerurl", :string
    t.column "proxy",       :integer, :limit => 4,   :default => 0
    t.column "brief",       :string
    t.column "descr",       :text
    t.column "fulltxt",     :string,  :limit => 2
    t.column "illreq",      :string,  :limit => 2
    t.column "fssub",       :string,  :limit => 2
    t.column "other",       :string
  end

  add_index "dods", ["title", "provider"], :name => "title"

  create_table "guides", :force => true do |t|
    t.column "guide_name",  :string,   :default => "",    :null => false
    t.column "resource_id", :integer
    t.column "updated_at",  :datetime
    t.column "created_by",  :string,   :default => "",    :null => false
    t.column "published",   :boolean,  :default => false, :null => false
    t.column "description", :text
  end

  create_table "guides_masters", :id => false, :force => true do |t|
    t.column "guide_id",  :integer
    t.column "master_id", :integer
  end

  add_index "guides_masters", ["guide_id"], :name => "index_guides_masters_on_guide_id"
  add_index "guides_masters", ["master_id"], :name => "index_guides_masters_on_master_id"

  create_table "guides_subjects", :id => false, :force => true do |t|
    t.column "guide_id",   :integer
    t.column "subject_id", :integer
  end

  add_index "guides_subjects", ["guide_id"], :name => "index_guides_subjects_on_guide_id"
  add_index "guides_subjects", ["subject_id"], :name => "index_guides_subjects_on_subject_id"

  create_table "guides_users", :id => false, :force => true do |t|
    t.column "guide_id", :integer
    t.column "user_id",  :integer
  end

  add_index "guides_users", ["guide_id"], :name => "index_guides_users_on_guide_id"
  add_index "guides_users", ["user_id"], :name => "index_guides_users_on_user_id"

  create_table "inst_resources", :force => true do |t|
    t.column "module_title",    :string,   :limit => 55, :default => "Course Instructor"
    t.column "label",           :string
    t.column "instructor_name", :string,   :limit => 55
    t.column "email",           :string
    t.column "office_location", :string,   :limit => 55
    t.column "office_hours",    :string,   :limit => 55
    t.column "website",         :string
    t.column "updated_at",      :datetime
    t.column "content_type",    :string,                 :default => "Instructor Profile"
    t.column "global",          :integer,  :limit => 4,  :default => 0
    t.column "created_by",      :string
  end

  create_table "lf_targets", :force => true do |t|
    t.column "libfind_resource_id", :integer
    t.column "value",               :string,  :limit => 55
  end

  create_table "lib_resources", :force => true do |t|
    t.column "module_title",    :string,   :limit => 55, :default => "Course Librarian"
    t.column "label",           :string
    t.column "librarian_name",  :string,   :limit => 55
    t.column "email",           :string
    t.column "chat_info",       :string
    t.column "office_hours",    :string,   :limit => 55
    t.column "office_location", :string,   :limit => 55
    t.column "chat_widget",     :text
    t.column "updated_at",      :datetime
    t.column "content_type",    :string,                 :default => "Librarian Profile"
    t.column "global",          :integer,  :limit => 4,  :default => 0
    t.column "created_by",      :string
  end

  create_table "libfind_resources", :force => true do |t|
    t.column "module_title", :string,                :default => "LibraryFind Search", :null => false
    t.column "label",        :string
    t.column "information",  :text
    t.column "updated_at",   :datetime
    t.column "content_type", :string,                :default => "LibraryFind Search"
    t.column "global",       :integer,  :limit => 4, :default => 0
    t.column "created_by",   :string
  end

  create_table "locals", :force => true do |t|
    t.column "banner_url",       :string, :default => "/images/template/local/banner_back.jpg"
    t.column "logo_url",         :string
    t.column "styles",           :text
    t.column "lib_name",         :string
    t.column "lib_url",          :string
    t.column "univ_name",        :string
    t.column "univ_url",         :string
    t.column "link_one",         :string
    t.column "link_two",         :string
    t.column "link_three",       :string
    t.column "name_one",         :string
    t.column "name_two",         :string
    t.column "name_three",       :string
    t.column "lib_help",         :string
    t.column "lib_chat",         :text
    t.column "footer",           :text
    t.column "book_search",      :text
    t.column "site_search",      :text
    t.column "g_search",         :text
    t.column "g_results",        :text
    t.column "image_map",        :text
    t.column "guide_page_title", :string, :default => "Get Help with a Subject"
    t.column "ica_page_title",   :string, :default => "Get Help with a Class"
  end

  create_table "masters", :force => true do |t|
    t.column "value", :string, :default => "", :null => false
  end

  create_table "miscellaneous_resources", :force => true do |t|
    t.column "module_title", :string,                :default => "Custom Information"
    t.column "label",        :string
    t.column "content",      :text
    t.column "more_info",    :text
    t.column "created_by",   :string
    t.column "updated_at",   :datetime
    t.column "global",       :integer,  :limit => 4, :default => 0
    t.column "content_type", :string,                :default => "Custom Content"
  end

  create_table "page_resources", :force => true do |t|
    t.column "page_id",     :integer
    t.column "resource_id", :integer
    t.column "position",    :integer
  end

  add_index "page_resources", ["page_id"], :name => "index_page_resources_on_page_id"
  add_index "page_resources", ["resource_id"], :name => "index_page_resources_on_resource_id"

  create_table "pages", :force => true do |t|
    t.column "template",         :integer,                :default => 2,     :null => false
    t.column "published",        :boolean,                :default => false, :null => false
    t.column "subject",          :string,                 :default => "",    :null => false
    t.column "sect_num",         :string
    t.column "course_name",      :string,                 :default => "",    :null => false
    t.column "term",             :string,                 :default => "",    :null => false
    t.column "year",             :string,                 :default => "",    :null => false
    t.column "campus",           :string,                 :default => "",    :null => false
    t.column "course_num",       :string,   :limit => 55
    t.column "page_description", :text
    t.column "updated_at",       :datetime
    t.column "created_on",       :date
    t.column "archived",         :integer,  :limit => 4,  :default => 0
    t.column "created_by",       :string
    t.column "resource_id",      :integer
  end

  create_table "pages_subjects", :id => false, :force => true do |t|
    t.column "page_id",    :integer
    t.column "subject_id", :integer
  end

  add_index "pages_subjects", ["page_id"], :name => "index_pages_subjects_on_page_id"
  add_index "pages_subjects", ["subject_id"], :name => "index_pages_subjects_on_subject_id"

  create_table "pages_users", :id => false, :force => true do |t|
    t.column "page_id", :integer
    t.column "user_id", :integer
  end

  add_index "pages_users", ["page_id"], :name => "index_pages_users_on_page_id"
  add_index "pages_users", ["user_id"], :name => "index_pages_users_on_user_id"

  create_table "plag_resources", :force => true do |t|
    t.column "module_title", :string,   :limit => 55, :default => "Plagiarism Information"
    t.column "label",        :string
    t.column "information",  :text
    t.column "updated_at",   :datetime
    t.column "content_type", :string,                 :default => "Plagiarism Information"
    t.column "global",       :integer,  :limit => 4,  :default => 0
    t.column "created_by",   :string
  end

  create_table "recom_resources", :force => true do |t|
    t.column "module_title",    :string,   :limit => 55, :default => "Instructor Recommendations"
    t.column "label",           :string
    t.column "recommendations", :text
    t.column "created_by",      :string
    t.column "updated_at",      :datetime
    t.column "global",          :integer,  :limit => 4,  :default => 0
    t.column "content_type",    :string,                 :default => "Recommendations"
  end

  create_table "reserve_resources", :force => true do |t|
    t.column "module_title",     :string,   :limit => 55, :default => "Course Reserves"
    t.column "label",            :string
    t.column "reserves",         :text
    t.column "library_reserves", :text
    t.column "course_title",     :string
    t.column "updated_at",       :datetime
    t.column "content_type",     :string,                 :default => "Course Reserves"
    t.column "global",           :integer,  :limit => 4,  :default => 0
    t.column "created_by",       :string
  end

  create_table "resources", :force => true do |t|
    t.column "mod_id",   :integer
    t.column "mod_type", :string
  end

  create_table "resources_users", :id => false, :force => true do |t|
    t.column "resource_id", :integer
    t.column "user_id",     :integer
  end

  add_index "resources_users", ["resource_id", "user_id"], :name => "resource_id"

  create_table "rss_resources", :force => true do |t|
    t.column "module_title", :string,   :limit => 55,  :default => "RSS Feeds"
    t.column "label",        :string,   :limit => 55
    t.column "rss_feed_url", :string,   :limit => 500
    t.column "updated_at",   :datetime
    t.column "content_type", :string,                  :default => "RSS Feeds"
    t.column "global",       :integer,  :limit => 4,   :default => 0
    t.column "created_by",   :string
  end

  create_table "sessions", :force => true do |t|
    t.column "session_id", :string
    t.column "data",       :text
    t.column "updated_at", :datetime
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "style_resources", :force => true do |t|
    t.column "module_title", :string,   :limit => 55, :default => "Style Guides"
    t.column "label",        :string,   :limit => 55
    t.column "information",  :text
    t.column "updated_at",   :datetime
    t.column "content_type", :string,                 :default => "Style Guides"
    t.column "global",       :integer,  :limit => 4,  :default => 0
    t.column "created_by",   :string
  end

  create_table "subjects", :force => true do |t|
    t.column "subject_code", :string, :default => "", :null => false
    t.column "subject_name", :string, :default => "", :null => false
  end

  create_table "tab_resources", :force => true do |t|
    t.column "tab_id",      :integer
    t.column "resource_id", :integer
    t.column "position",    :integer
  end

  add_index "tab_resources", ["tab_id"], :name => "index_tab_resources_on_tab_id"
  add_index "tab_resources", ["resource_id"], :name => "index_tab_resources_on_resource_id"

  create_table "tabs", :force => true do |t|
    t.column "tab_name",   :string,   :limit => 20
    t.column "guide_id",   :integer
    t.column "updated_at", :datetime
    t.column "position",   :integer
    t.column "template",   :integer,                :default => 2
  end

  create_table "taggings", :force => true do |t|
    t.column "tag_id",        :integer
    t.column "taggable_id",   :integer
    t.column "taggable_type", :string
    t.column "created_at",    :datetime
  end

  add_index "taggings", ["tag_id"], :name => "tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "taggable_id"

  create_table "tags", :force => true do |t|
    t.column "name", :string
  end

  create_table "users", :force => true do |t|
    t.column "name",          :string,  :default => "",       :null => false
    t.column "hashed_psswrd", :string,  :default => "",       :null => false
    t.column "email",         :string,  :default => "",       :null => false
    t.column "salt",          :string,  :default => "",       :null => false
    t.column "role",          :string,  :default => "author", :null => false
    t.column "rid",           :integer
  end
end
