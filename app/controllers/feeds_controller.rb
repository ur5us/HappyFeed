class FeedsController < ApplicationController
  before_action :ensure_logged_in!

  def index
    @feeds = current_user.feeds.order(:title)
    @feed = Feed.new
  end

  def show
    @feed = current_user.feeds.find(params[:id])
    @feed_items = @feed.feed_items.page(params[:page])
  end

  def create
    feed = Feed.find_or_create_by(feed_url: feed_params[:feed_url])

    if current_user.subscribe(feed, feed_params[:group_id])
      redirect_to feeds_path, notice: 'Feed added!'
    else
      redirect_to feeds_path, alert: "Could not subscribe to Feed! Wrong URL?"
    end
  end

  def destroy
    feed = current_user.feeds.find(params[:id])

    if current_user.unsubscribe(feed)
      redirect_to feeds_path
    end
  end

  def discover
    feed_url = feed_params[:feed_url]

    if Feedbag.feed?(feed_url)
      @feed_urls = [feed_url]
    else
      @feed_urls = []
      feed_urls = Feedbag.find(feed_url)
      feed_urls.each do |feed_url|
        @feed_urls << feed_url if Feedbag.feed?(feed_url)
      end
    end

    respond_to do |format|
      format.json
    end
  end

  private

    def feed_params
      params.require(:feed).permit(:feed_url, :group_id)
    end
end
