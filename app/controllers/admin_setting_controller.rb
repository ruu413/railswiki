class AdminSettingController < ApplicationController
    before_action :authenticate_user!
    def index
      if(!is_editable?)
        error_404
        return
      end
      @users = User.all.order("admin DESC")
    end
    def update
      if(!is_editable?)
        error_404
        return
      end
      user = User.find_by(id:params[:user_id].to_i)
      if(user == current_user)
        redirect_to :action => "index"
        return
      end
      if(params[:admin] == "true"&&!user.admin)
        user.update(admin: true)
      elsif(params[:admin] == "false"&&user.admin)
        user.update(admin: false)
      end
      redirect_to :action => "index"
    end
    def error_404
      
      raise ActionController::RoutingError,params[:pages]#とりあえず404なげる（めんどい）
    end
    def is_editable?
      if is_admin? current_user
        return true
      end
      return false
    end
  
end
