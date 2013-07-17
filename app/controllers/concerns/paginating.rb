require 'will_paginate/array'

module Paginating
  extend ActiveSupport::Concern

  def paginate_guides guides, pagin, sort
    guides.paginate per_page: 25, page: pagin.to_i
  end

  def paginate_list objects, pagin, sort
    objects.paginate per_page: 25, page: pagin.to_i
  end

  def paginate_mods mods, pagin, sort
    mods.paginate per_page: 25, page: pagin.to_i
  end

  def paginate_pages pages, pagin, sort
    pages.paginate per_page: 25, page: pagin.to_i
  end
end
