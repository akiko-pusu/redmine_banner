module BannerHelper
  def escape_single_quote(data)
    return data.gsub("'","&rsquo;") 
  end
end
