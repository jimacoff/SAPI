class SourceSweeper < ActionController::Caching::Sweeper
  observe Source

  def after_create(tc)
    expire_cache(tc)
  end

  def after_update(tc)
    expire_cache(tc)
  end

  def after_destroy(tc)
    expire_cache(tc)
  end

  private

  def expire_cache(tc)
    expire_action(:controller => "api/v1/sources", :action => "index")
  end
end
