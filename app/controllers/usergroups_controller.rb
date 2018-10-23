class UsergroupsController < ApplicationController
  def index
    @usergroups=Usergroup.all
    @users=Users.all
  end
  def new
  end
  def create
  end
  def show
  end
  def edit
  end
  def update
  end
  def destroy
  end
end
