module BannerHelper  
  def get_time(ymd, h, m)
    d = Date.strptime(ymd, "%Y-%m-%d")
    return Time.mktime(d.year, d.month, d.day, h.to_i, m.to_i)
  end
end