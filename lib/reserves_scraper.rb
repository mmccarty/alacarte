require 'open-uri'

module ReservesScraper
  OASIS_DOMAIN = "oasis.library.oregonstate.edu"
  BASE_URI = "http://oasis.library.oregonstate.edu"
  SEARCH_URI = "http://oasis.library.oregonstate.edu/search~S13/r?SEARCH="

  def search_reserves(course=nil, uri=nil)
    if course
      scrape(get_page(course.gsub(/\s/, '+')))
    elsif uri
      scrape(get_page(nil, uri))
    else
      nil
    end
  end

  def get_page(course=nil, uri=nil)
    if uri.nil?
      uri = SEARCH_URI + course
    else
      uri = BASE_URI + uri
    end
    res = Hpricot(open(uri))
    res
  end

  def scrape(page)
    matches = []
    if ((page/"tr.browseHeader").length > 0)
      #We have multiple courses returned, we need to harvest links to them.
      #This happens in the case of multiple teachers of the same course or multiple 
      #locations (Cascades campus as well as Corvallis).
      (page/"td.browseEntryData").each do |be|
                matches << {:course => be.inner_html}
      end
    else
      #We have results for a specific course, time to strip reserve infos.  
      (page.search('body').to_s).scan(/\<\/tr\>\n[\<\/form\>\n]*\<tr\>\n(.*)\<\/tr\>/mi) do |s|
        count = 0
        match = {}
        s.first.scan(%r{<td\b[^>]*>[&nbsp;\n]*(.*?)</td>}mi ) do |r| 
          case count % 4
          when 0
            match[:title] = r.first.insert(r.first.index(/href="/) + 6, "http://#{OASIS_DOMAIN}")
          when 1
            match[:author] = r
          when 2
            r.first =~ /\D -- ([\w . \/]*) / ; match[:availability] = $1 if $1
          else 
            match[:id] = count / 4 ; matches << match ; match = {}
          end
          count += 1
        end
      end
    end
    return matches
  end
end
