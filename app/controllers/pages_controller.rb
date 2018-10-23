class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:new,:edit,:create,:update]
  #before_action ->{renderleft("")},only: [:index,:new,:create]
  protect_from_forgery except: :create
  def get_parent_title(name,num)#切り取る数
    if name==nil
      @parent=""
      @title=""
      return
    end
    @parent = name.split("/")
    num.times do
      @parent.pop
    end
    @title=@parent.pop
    @parent=@parent.join("/")
    #while @parent[0]=='/' do @parent=@parent[1,1000] end
    if @title==nil
      @title=""
    end
    if @parent==nil
      @parent=""
    end
  end
  def index
    get_parent_title(params[:pages],0)
    @path=createpath(@parent,@title)
    #@right_content="a";
    #@left_content="b";
    @page=Page.where(parent:@parent).find_by(title:@title)
    if @page != nil
      @content = CommonMarker.render_html(@page.content)
    else
      @content = "未作成"
    end
    renderleft(@path[1,1000])
  end
  def new
    get_parent_title(params[:pages],0)
    @path=createpath(@parent,@title)
    renderleft(@path[1,1000])
    @page=Page.where(parent:@parent).find_by(title:@title)
    if @page!=nil
      redirect_to(@path+"/edit")
    end
  end
  def create
    @last_edit_user_id=current_user.id
    get_parent_title(params[:pages],1)
    @path=createpath(@parent,@title)
    @content = ERB::Util.html_escape(params[:content])
    if Page.where(parent:@parent).find_by(title:@title)==nil
      Page.create!(
        last_edit_user_id: @last_edit_user_id,
        parent: @parent,
        title:  @title,
        content: @content,
        )
    end
    redirect_to(@path)
  end
  def edit
    get_parent_title(params[:pages],0) 
    @path=createpath(@parent,@title)
    renderleft(@path[1,1000])
    @page=Page.where(parent:@parent).find_by(title:@title)
    if @page==nil
      redirect_to(@path+"/new")
      return
    end
    @content=@page.content
  end
  def update
    get_parent_title(params[:pages],1)
    @path=createpath(@parent,@title)
    @content = ERB::Util.html_escape(params[:content])
    @page=Page.where(parent:@parent).find_by(title:@title)
    if @page!=nil
      @page.update!(content:@content)
    end
    redirect_to(@path)
  end
  def destroy
  end
  def renderleft str
    if str == nil then str = "" end
    @left_content = Page.where(parent:str)
  end
  def renderright str
  end
  def createpath( parent, title)
    if parent==""||parent==nil
      if title==""||title==nil
        return ""
      else
        return "/"+title
      end
    else
      return "/"+parent+"/"+title
    end
  end
end
