json.array! @mods do |mod|
  json.(mod, :id, :published, :global)
  json.label(mod.label.html_safe)
  json.shared(mod.shared? ? 'shared' : 'not shared')
  json.used(mod.used?)
  json.updated_at(mod.updated_at.to_date)
end