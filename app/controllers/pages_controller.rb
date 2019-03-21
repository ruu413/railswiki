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
    if params[:format]==nil
      page_show
    else
      file_show
      #render :nothing=>true and return
    end
  end
  def file_show
    get_parent_title(params[:pages],0)
    filename=@title+"."+params[:format]
    get_parent_title(params[:pages],1)
    page=Page.where(parent:@parent).find_by(title:@title)
    file=nil
    file=page.uploadfiles.find_by(file_name:filename)
    if file!=nil
      filedata = File.open(file.file_path,"r").read
      send_data(filedata,filename:file.file_name,:disposition=>"inline")
    else
      #render :staturs=>404  
      #後でno imageでも返すようにする
    end
    #render :nothing=>true and return
  end
  def page_show
    force_trailing_slash
    get_parent_title(params[:pages],0)
    #send_data(Uploadfile.find(2).file.download,filename:"a.png",:disposition=>"inline")
    @path=createpath(@parent,@title)
    #if(params[:pages][params[:pages].size-1]!='/')
    #  redirect_to(@path)
    #  return
    #end
    #@right_content="a";
    #@left_content="b";
    @page=Page.where(parent:@parent).find_by(title:@title)
    renderleft(@path[1,1000])
    if @page != nil
      if is_editable?(@page)#編集権限を持つ
        @editable=true
      end
      if is_readable?(@page)
        @content = CommonMarker.render_html(@page.content)
      else
        @page =nil
        @content=""
      end
    else
      @content = "未作成"
    end
  end
  def new
    if(!user_signed_in?)
      redirect_to @path
      return
    end
    get_parent_title(params[:pages],0)
    @commongroup="<option value='nil'>全員</option><option value='0'>自分のみ</option>"
    @path=createpath(@parent,@title)
    @usergroups=Usergroup.all
    renderleft(@path[1,1000])
    @page=Page.where(parent:@parent).find_by(title:@title)
    if @page!=nil
      redirect_to(@path+"/edit")
    end
    @content=''
    @method='post'
  end
  def create
    get_parent_title(params[:pages],0)
    page=Page.where(parent:@parent).find_by(title:@title)
    path = createpath(@parent,@title)
    if(!user_signed_in?)
      return
    end
    if(params[:content]!=nil)
      page_create
    end
    if(params[:comment]!=nil)
      if(page!=nil && is_readable?(page))
        comment_create
      end
    end
    file_=params[:files]
    if file_!=nil && page!=nil&&is_editable?(page)
      file_create file_,page
    end
    redirect_to path
    return
  end
  def comment_create
    get_parent_title(params[:pages],0)
    page=Page.where(parent:@parent).find_by(title:@title)
    if(page==nil)then return end
    comment=page.comments.create(comment:ERB::Util.html_escape(params[:comment]))
    current_user.comments<<comment
  end
  def page_create
    @last_edit_user_id=current_user.id
    get_parent_title(params[:pages],1)
    @path=createpath(@parent,@title)
    if(Page.where(parent:@parent).find_by(title:@title))
      update
      return
    end
    @usergroups=Usergroup.all
    if params[:readable_group_id]=="nil"
      readable_group_id=nil
    else
      readable_group_id=params[:readable_group_id].to_i
    end
    if params[:editable_group_id]=="nil"
      editable_group_id=nil
    else
      editable_group_id=params[:editable_group_id].to_i
    end
    
    @content = ERB::Util.html_escape(params[:content])
    if Page.where(parent:@parent).find_by(title:@title)==nil
      page=Page.create!(
        last_edit_user_id: @last_edit_user_id,
        parent: @parent,
        title:  @title,
        content: @content,
        readable_group_id: readable_group_id,
        editable_group_id: editable_group_id
      )
      #page.files.attach(params[:file][:files])
      #get_parent_title(params[:pages],0)
      #send_data(Uploadfile.find(1).file.download,filename:"a.png")
      #page.update(uploadfiles_files: files)
      #if files
      # page.files.attach(files)
      #end
      #a.find
      #files.each do |file|
      #  page.uploadfiles.attach(file)
      #end
    end
  end
  def file_create file_param,page
    get_parent_title(params[:pages],0)
    @path=createpath(@parent,@title)
    output_dir=Rails.root.join('storage/files'+@path,"")
    FileUtils.mkdir_p(output_dir,:mode => 755)
    output_path = Rails.root.join('storage/files'+@path,file_param.original_filename)
    
    file = Uploadfile.create(
      file_name: file_param.original_filename,
      file_content_type: file_param.content_type,
      #file: file_.tempfile.open.read
      file_path: output_path
    ) 
    File.open(output_path, 'w+b') do |fp|
      fp.write  file_param.read
    end
    page.uploadfiles<<file
  end
  
  def edit
    if(!user_signed_in?)
      redirect_to @path
      return
    end
    @commongroup="<option value='nil'>全員</option><option value='0'>自分のみ</option>"
    get_parent_title(params[:pages],0) 
    @path=createpath(@parent,@title)
    renderleft(@path[1,1000])
    @page=Page.where(parent:@parent).find_by(title:@title)
    
    if !is_editable? @page
      redirect_to(@path)
      return
    end
    @usergroups=Usergroup.all
    if @page==nil
      redirect_to(@path+"/new")
      return
    end
    @content=@page.content
    @method='put'
    render :action=>'new'
  end
  def update
    get_parent_title(params[:pages],1)
    @path=createpath(@parent,@title)
    
    @page=Page.where(parent:@parent).find_by(title:@title)
    if(!is_editable? @page)
      redirect_to @path
      return
    end
    @content = ERB::Util.html_escape(params[:content])

    if params[:readable_group_id]=="nil"
      readable_group_id=nil
    else
      readable_group_id=params[:readable_group_id].to_i
    end
    if params[:editable_group_id]=="nil"
      editable_group_id=nil
    else
      editable_group_id=params[:editable_group_id].to_i
    end
    if @page!=nil
      @page.update!(content:@content,readable_group_id:readable_group_id,editable_group_id:editable_group_id)
    end
    redirect_to(@path)
  end
  def destroy
    get_parent_title(params[:pages],0)
    path = createpath(@parent,@title)
    if !user_signed_in? 
      redirect_to path
      return
    end
    page=Page.where(parent:@parent).find_by(title:@title)
    if params[:comment_id]!=nil
      comment_destroy
    elsif params[:file_id]!=nil
      if is_editable? page
        file_destroy
      end
    else
      if is_editable? page
        page_destroy
      end
    end
    redirect_to path
  end
  def page_destroy
    get_parent_title(params[:pages],0)
    page=Page.where(parent:@parent).find_by(title:@title)
    if page!=nil
      page.destroy
    end
  end
  def file_destroy
    get_parent_title(params[:pages],0)
    page=Page.where(parent:@parent).find_by(title:@title)
    file = page.uploadfiles.find(params[:file_id].to_i)
    if file !=nil
      file.destroy
    end
  end
  def comment_destroy
    get_parent_title(params[:pages],0)
    page=Page.where(parent:@parent).find_by(title:@title)
    comment = page.comments.find(params[:comment_id].to_i)
    if comment !=nil
      comment.destroy
    end
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
        return "/"+title+"/"
      end
    else
      return "/"+parent+"/"+title+"/"
    end
  end
  def is_editable? page
    if page == nil||!user_signed_in?
      return false
    elsif page.editable_group_id == nil
      return true
    elsif page.editable_group_id == 0
      if(current_user!=nil&& page.last_edit_user_id==current_user.id)
        return true
      else
        return false
      end
    end
    begin
      if Usergroup.find(page.editable_group_id).users.ids.include?(current_user.id)
        return true
      else
        return false
      end
    rescue ActiveRecord::RecordNotFound
      return true
    end
    return false
  end

  def is_readable? page
    if page.readable_group_id ==nil
      return true
    elsif page.readable_group_id == 0
      if(current_user!=nil&& page.last_edit_user_id==current_user.id)
        return true
      else
        return false
      end
    elsif user_signed_in?
      return false
    end
    
    begin
      if Usergroup.find(page.readable_group_id).users.ids.include?(current_user.id)
        return true
      else
        return false
      end
    rescue ActiveRecord::RecordNotFound
      return true
    end
    return false
  end
end
