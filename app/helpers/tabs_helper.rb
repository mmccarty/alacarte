module TabsHelper
  def polymorphic_partial parent, partial
    render "#{ parent.class.name.pluralize.underscore }/#{ partial }"
  end
end
