#Submitting a search query to Oasis, and then scraping the results. 

require 'net/http'

module ReservesScraper
  OASIS_DOMAIN = "oasis.library.oregonstate.edu"
  SEARCH_URI = "http://oasis.library.oregonstate.edu/search/r"
  FORM_FIELD_NAME = "SEARCH"

  def search_reserves(course=nil, uri=nil)
    if course
      return scrape(get_page(course))
    elsif uri
      return scrape(get_page(nil, uri))
    else
      return nil
    end
  end

  def get_page(course=nil, uri=nil)
    if uri.nil?
      uri = URI.parse(SEARCH_URI)
      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data({FORM_FIELD_NAME => course})
    else
      req = Net::HTTP::Get.new(uri)
    end

    res = Net::HTTP.new(OASIS_DOMAIN).start { |http| http.request(req) }
    raise if res.value
    return res
  end

  def scrape(page)
    matches = []

    if match = /\<td align="center" class="browseHeaderData".*?COURSES.*?\<\/td\>/mi.match(page.body)
      #We have multiple courses returned, we need to harvest links to them.
      #This happens in the case of multiple teachers of the same course or multiple 
      #locations (Cascades campus as well as Corvallis).
      page.body.scan(/\<td class="browseEntryData"\>\n(.*?)&nbsp;.*?\<\/td\>/mi) { |m|
        matches << {:course => m.first}
      }
    else
      #We have results for a specific course, time to strip reserve infos.
      page.body.scan(/\<\/tr\>[\n]*\<tr\>(.*)\<\/tr\>/mi) { |s|
        count = 0
        match = {}
        s.first.scan(/\<td \>\n&nbsp;(.*?)\<\/td\>/mi) { |r| 
          case count % 4
            when 0: match[:title] = r.first.insert(r.first.index(/href="/) + 6, "http://#{OASIS_DOMAIN}")
            when 1: match[:author] = r
            when 2: r.first =~ /\w -- ([\d\w \/]*) / ; match[:availability] = $1 if $1
            else match[:id] = count / 4 ; matches << match ; match = {}
          end
          count += 1
        }
      }
    end
    return matches
  end
end
