require 'rails_helper'

describe Group do

  it { should belong_to :user }
  it { should have_and_belong_to_many :feeds }
  it { should have_many(:feed_items).through(:feeds) }

  before do
    stub_request(:get, "http://need.computer/posts.atom").to_return(File.new('spec/feed_response_raw.txt'))

    @user = FactoryGirl.create(:user)
    @feed = FactoryGirl.create(:feed, feed_url: 'http://need.computer/posts.atom')
  end

  it 'can add Feeds to a Group' do
    expect(@user.groups.first.feeds.exists?(@feed.id)).to be false
    @user.groups.first.add_feed(@feed)
    expect(@user.groups.first.feeds.find(@feed.id).present?).to be true
  end

  it 'can remove Feeds from a Group' do
    @user.groups.first.add_feed(@feed)
    expect(@user.groups.first.feeds.find(@feed.id).present?).to be true

    @user.groups.first.remove_feed(@feed)
    expect(@user.groups.first.feeds.exists?(@feed.id)).to be false
  end

  it 'moves existing subscriptions to the default group if a group gets removed' do
    random_group = FactoryGirl.create(:group, default: nil)
    @user.groups.find(random_group.id).add_feed(@feed)
    expect(@user.groups.find(random_group.id).feeds.find(@feed.id).present?).to be true

    @user.groups.find(random_group.id).destroy

    expect(@user.groups.first.feeds.find(@feed.id).present?).to be true
  end

end
