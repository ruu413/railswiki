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
    usergroup=Usergroup.create(
    create_user_id: current_user.id,
    name: params[:usergroup][:name]
    )
    params[:usergroup][:check_id].each do |s|
      usergroup.users<<User.find(s.to_i)
    end
    redirect_to :action => "index"
  end
  def show
    force_trailing_slash
    id=params[:id]
    begin
      @usergroup=Usergroup.find(id.to_i)
    rescue
      #404吐く？
      redirect_to :action => "index"
    end
  end
  def edit
    id=params[:id]
    begin
      @usergroup=Usergroup.find(id.to_i)
    rescue 
      redirect_to :action =>"new"
      return
    end
    if(@usergroup.create_user_id != current_user.id)
      #redirect_to :action => "index"
      #return
    end
    @users=User.all
  end
  def update
    id=params[:id]
    begin
      usergroup=Usergroup.find(id.to_i)
    rescue 
      redirect_to :action =>"index"
      return
    end
    usergroup.update(
      name:params[:usergroup][:name]
    )
    usergroup.clear
    params[:usergroup][:check_id].each do |s|
      usergroup.users<<User.find(s.to_i)
    end
    redirect_to :action => "index"
  end
  def destroy
    begin
      usergroup=Usergroup.find(id.to_i)
    rescue 
      redirect_to :action =>"index"
      return
    end
    if(usergroup.create_user_id == current_user.id)
      Usergroup.find(params[:id]).destroy!
    end
    redirect_to :action => "index"
  end
end
