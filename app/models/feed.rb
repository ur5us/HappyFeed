class Feed < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  has_many :feed_items, dependent: :destroy

  validates :feed_url, :group_id, presence: true
  validates :feed_url, uniqueness: { scope: :user_id, message: "should happen once per year" }

  before_create do
    self.feed_url = discover_feed_url(feed_url.strip)
  end

  private

    def discover_feed_url(feed_url)
      feeds = Feedbag.find(feed_url)
      feeds.each do |feed|
        return feed if Feedbag.feed?(feed)
      end
    end
end
