class ApplicationController < ActionController::Base
  def force_trailing_slash
    url = request.original_url
    url_ = url.split("?")
    if url_.size >1
        option = url_.pop
    end
    if option != "" &&option !=nil
        option = "?"+option
    end
    url_body = url_.join
    if(url_body == nil)
        url_body = ""
    end
    redirecturl = url_body
    redirecturl += "/" unless url_body.match(/\/$/)
    if option != nil
        redirecturl += option
    end
    if redirecturl != url
        redirect_to redirecturl
    end
  end

  def is_admin? user
    if user.admin
      return true
    end
    return false
  end
end