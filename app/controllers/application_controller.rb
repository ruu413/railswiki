class ApplicationController < ActionController::Base
end
def force_trailing_slash
    redirect_to "#{request.original_url}/" unless request.original_url.match(/\/$/)
end