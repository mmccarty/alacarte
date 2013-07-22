require 'spec_helper'

describe Comment do
  it 'has a valid factory' do
    expect(build :comment).to be_valid
  end

  it 'requires a message body' do
    expect(build :comment, body: nil).to have(1).errors_on :body
  end

  it 'is invalid of the message body contains a blocked word' do
    expect(build :comment, body: "You're web site sucks ass.").to have(1).errors_on :body
  end

  it 'does not require an email address' do
    expect(build :comment, author_email: nil).to be_valid
  end

  it 'requires email addresses to be in a valid format' do
    expect(build :comment, author_email: 'this is not an email address').to have(1).errors_on :author_email
  end

  it 'prohibits messages containing blocked words' do
    expect(build :comment, body: 'crap').to_not be_is_clean
  end

  it 'allows messages not containing any blocked words' do
    expect(build :comment, body: "I love you're web site!").to be_is_clean
  end
end
