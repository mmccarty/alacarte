class Taggings < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable
end
