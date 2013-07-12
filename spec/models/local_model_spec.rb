require 'spec_helper'

describe Local do
  it 'should list all defined guide types' do
    expect(Local.create.guides.sort).to eq %w(guides pages tutorials)
  end

  it 'should list all defined module types' do
    expect(Local.create.types).to eq [
      'comment_resource', 'miscellaneous_resource', 'database_resource', 'inst_resource',
      'lib_resource', 'quiz_resource', 'rss_resource', 'url_resource',
    ]
  end

  it 'should list the friendly names of all defined module types' do
    expect(Local.create.mod_types.map { |m| m[0] }.sort).to eq [
      'Comments', 'Custom Content', 'Databases', 'Instructor Profile', 'Librarian Profile',
      'Quiz', 'RSS Feeds', 'Web Links'
    ]
  end
end
