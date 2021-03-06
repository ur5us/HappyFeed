class FeedItem < ActiveRecord::Base
  include FeedItemHelper

  belongs_to :feed
  has_many :feed_item_reads
  has_many :feed_item_stars

  validates :feed_id, :title, :url, presence: true

  scope :clean, -> { where cleaned: true }

  def mark_as(mark, user_id)
    case mark
      when 'read'
        unless feed_item_reads.find_by(feed_item_id: id, user_id: user_id)
          feed_item_reads.create(feed_id: feed_id, user_id: user_id)
        end
      when 'unread'
        feed_item_reads.find_by(feed_item_id: id, user_id: user_id).try(:destroy)
      when 'saved'
        unless feed_item_stars.find_by(feed_item_id: id, user_id: user_id)
          feed_item_stars.create(feed_id: feed_id, user_id: user_id)
        end
      when 'unsaved'
        feed_item_stars.find_by(feed_item_id: id, user_id: user_id).try(:destroy)
    end
  end

  def next_item
    FeedItem.clean.where('id > ? AND feed_id = ?', self.id, self.feed_id).limit(1).first
  end

  def previous_item
    FeedItem.clean.where('id < ? AND feed_id = ?', self.id, self.feed_id).last
  end

  def word_count
    html.split(' ').count
  end

  def length_in_time(wpm = 130)
    word_count.to_f / wpm.to_f
  end

end
