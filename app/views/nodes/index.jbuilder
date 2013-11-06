json.array! @mods do |mod|
  json.(mod, :id, :published, :global, :content, :tag_list)
  json.label(mod.label.html_safe)
  json.module_title(mod.module_title.html_safe)
  json.shared(mod.shared?)
  json.used(mod.used?)
  json.updated_at(mod.updated_at.to_date)
end