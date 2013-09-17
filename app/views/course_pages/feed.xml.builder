<% render :partial => "shared/feed.xml.builder",
          :locals => { :title => @page_title,
                       :link => @page_url,
                       :description => @page_description } %>