require 'rails_helper'

feature 'Feeds Mangement' do

  before(:each) do
    @user = FactoryGirl.create(:user)

    visit login_path
    fill_in 'login_email', with: 'user@happyfeed.tld'
    fill_in 'login_password', with: 'password'
    click_button 'Login'
  end

  scenario 'Add a Feed' do
    visit feeds_path
    expect(page).to have_content 'Add a new Feed'

    fill_in 'feed_feed_url', with: 'http://heise.de'
    select 'Default Group', from: 'feed_group_id'

    click_button 'Create Feed'

    expect(User.find(@user.id).feeds.first.feed_url).to eq 'http://www.heise.de/newsticker/heise-atom.xml'
    expect(User.find(@user.id).feeds.first.group.title).to eq 'Default Group'
  end

  scenario 'Add a Feed to another Group (Edit)' do
    FactoryGirl.create(:feed, feed_url: 'http://heise.de')
    FactoryGirl.create(:group, title: 'My New Group')

    visit feeds_path

    click_link 'edit'
    expect(page).to have_content 'Edit Feed'

    select 'My New Group', from: 'feed_group_id'

    click_button 'Update Feed'

    expect(User.find(@user.id).feeds.first.group.title).to eq 'My New Group'
  end

  scenario 'Unsubscribe from a Feed' do
    FactoryGirl.create(:feed, feed_url: 'http://heise.de')

    visit feeds_path

    click_link 'edit'
    expect(page).to have_content 'Edit Feed'

    click_link 'unsubscribe'

    expect(page).to have_content 'Add a new Feed' # after redirect to feeds_path
    expect(User.find(@user.id).feeds.count).to eq 0
  end
end
