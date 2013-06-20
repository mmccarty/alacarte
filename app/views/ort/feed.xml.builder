<% render :partial => "shared/feed.xml.builder",
          :locals => { :title => @ptitle,
                       :link => @url,
                       :description => @description } %>