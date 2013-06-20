<% render :partial => "shared/feed.xml.builder",
          :locals => { :title => @guide_title,
                       :link => @guide_url,
                       :description => @guide_description } %>