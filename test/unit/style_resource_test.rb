require File.dirname(__FILE__) + '/../test_helper'

class StyleResourceTest < Test::Unit::TestCase
  fixtures :style_resources

  def test_create_read_update_delete
    #create
    stylemod = StyleResource.new(:module_title => "Style Guides", :saved_name => "My Guide to Style", :information => "Style Guide")
    assert stylemod.save
    #read
    mod = StyleResource.find(stylemod.id)
    assert_equal mod.saved_name, stylemod.saved_name
    #update
    mod.saved_name = " "
    assert mod.save
    #delete
    assert mod.destroy
  end

  def test_validation
    #check that we can't create a StyleResource without all the required values
    #no module_title
    stylemod = StyleResource.new(:saved_name => "My Style", :information => "Style")
    assert stylemod.save
    stylemod.module_title = ""
    assert !stylemod.save
    assert stylemod.errors.invalid?('module_title')
  end

  def test_saved
    stylemod = StyleResource.new(:saved_name => "My Style", :information => "Style")
    assert stylemod.save
    assert_equal stylemod.make_qs, true
    stylemod.saved_name = ""
    assert stylemod.save
    assert_equal stylemod.make_qs, false
  end
end
