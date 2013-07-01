require 'will_paginate/array'

module Paginating
  extend ActiveSupport::Concern

  def paginate_mods(mods, pagin, sort)
    page = (pagin).to_i
    items_per_page = 25
    mods = mods.paginate :per_page => items_per_page, :page => page , :order => sort
    mods
  end
  
  def paginate_guides(guides, pagin, sort)
    page = (pagin).to_i
    items_per_page = 25
    guides = guides.paginate :per_page => items_per_page, :page => page, :order => sort        
    guides
  end 

  def paginate_pages(pages, pagin, sort)
    page = (pagin).to_i
    items_per_page = 25
    pages = pages.paginate :per_page => items_per_page, :page => page , :order => sort         
    pages
  end

  def paginate_list(objects, pagin, sort)
    page = (pagin).to_i
    items_per_page = 25
    objects = objects.paginate :per_page => items_per_page, :page => page , :order => sort         
    objects
  end
end
