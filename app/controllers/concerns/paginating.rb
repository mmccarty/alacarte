require 'will_paginate/array'

module Paginating
  extend ActiveSupport::Concern

  %w(guides list mods pages).each do |thing|
    define_method "paginate_#{ thing }" do |thing, pagin, sort|
      thing.paginate per_page: 25, page: pagin.to_i
    end
  end
end
