module HasModules
  extend ActiveSupport::Concern

  def add_tags tags
    self.tag_list = tags
    self.save
  end

  def modules
    resources.map(&:mod).compact
  end

  def recent_modules
    modules.sort_by &:updated_at
  end

  def find_resource id, type
    resources.find_by_mod_id_and_mod_type id, type
  end

  def add_module id, type
    add_resource Resource.find_by_mod_id_and_mod_type(id, type)
  end

  def add_resource resource
    resources << resource
    update_users
  end

  def update_resource resrs
    resrs.each do |value|
      id = value.gsub /[^0-9]/, ''
      type = value.gsub /[^A-Za-z]/, ''
      resource = Resource.find_by_mod_id_and_mod_type id, type
      resource.create_slug if resource.mod.slug.blank?
      resources << resource
    end
  end
end
