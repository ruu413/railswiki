class UsergroupsController < ApplicationController
  def index
    force_trailing_slash
    @usergroups=Usergroup.all
    @users=User.all
  end
  def new
    @users=User.all
  end
  def create
    name = ERB::Util.html_escape(params[:usergroup][:name])
    if(name==nil||params[:usergroup][:check_id]==nil)
      redirect_to :action => "index"
      return
    end
    if(Usergroup.find_by(name: name))
      redirect_to :action => "index"
      return
    end
    usergroup=Usergroup.create(
    create_user_id: current_user.id,
    name: name
    )
    params[:usergroup][:check_id].each do |s|
      user = User.find_by(id:s.to_i)
      if user
        usergroup.users<<user
      end
    end
    redirect_to :action => "index"
    return
  end
  def show
    #force_trailing_slash
    id=params[:id]
    @usergroup=Usergroup.find(id.to_i)
  end
  def edit
    id=params[:id]
    
    @usergroup=Usergroup.find(id.to_i)
    if(@usergroup.create_user_id != current_user.id)
      #redirect_to :action => "index"
      #return
    end
    @users=User.all
  end
  def update
    id=params[:id]
    
    usergroup=Usergroup.find(id.to_i)
    if usergroup
      redirect_to :action =>"index"
      return
    end
    usergroup.update(
      name:params[:usergroup][:name]
    )
    usergroup.clear
    params[:usergroup][:check_id].each do |s|
      user =User.find_by(id:s.to_i)
      if(user)
        usergroup.users<<user
      end
    end
    redirect_to :action => "index"
    return
  end
  def destroy
    id = params[:id]
    
    usergroup=Usergroup.find(id.to_i)
    if(usergroup.create_user_id == current_user.id)
      usergroup.destroy!
    end
    redirect_to :action => "index"
    return
  end
end
