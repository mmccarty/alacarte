require 'spec_helper'

describe Local do
  it 'should list all defined guide types' do
    expect(Local.create.guides).to match_array %w(guides pages)
  end

  it 'should list all defined module types' do
    expect(Local.create.types).to eq [
      'miscellaneous_resource', 'database_resource', 'inst_resource',
      'lib_resource', 'rss_resource', 'url_resource',
    ]
  end

  it 'should list the friendly names of all defined module types' do
    expect(Local.create.mod_types.map { |m| m[0] }).to match_array [
      'Custom Content', 'Databases', 'Instructor Profile', 'Librarian Profile',
      'RSS Feeds', 'Web Links'
    ]
  end
end
