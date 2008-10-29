module ModuleHelper


  
  
# Helper method that determines which form to show when editing a module.
# Determination is based on the mod_type parameter.
def show_form(mod_type)
     render :partial => mod_type.underscore+'_form'
end




#
# helper method to determine which module-specific help to show. 
def show_help(mod_type)
   render :partial => mod_type.underscore+'_help'
end





def is_more?
   if @mod.more_info.nil? || @mod.more_info.empty?
     return true
   else
     return false
   end
end
  
end
