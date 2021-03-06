class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:new,:edit,:create,:update]
  #before_action ->{renderleft("")},only: [:index,:new,:create]
  #protect_from_forgery except: :create
 
  #pathを親とタイトル要素に分けて parent,titleで返す
  def get_parent_title(name,num)#切り取る数
    if name==nil
      parent=""
      title=""
      return parent,title
    end
    parent = name.split("/")
    num.times do
      parent.pop
    end
    title=parent.pop
    parent=parent.join("/")
    #while @parent[0]=='/' do @parent=@parent[1,1000] end
    if title==nil
      title=""
    end
    if parent==nil
      parent=""
    end
    return parent,title
  end

  # settings/以外のgetで呼ばれる
  # paramによって処理を分ける
  #　?search 検索
  #　?new   新規ページ作成
  #　?edit 既存ページ編集
  #　?format /[.]/があった時 ファイル表示
  # それらの要素がなかった時 ページ表示
  def index
    if(params[:search]!=nil)
      search
      return
    elsif(params[:new]!=nil)
      new
      render :action=>"new"
      return
    elsif(params[:edit]!=nil)
      edit
      #render :action=>"edit"
      return
    elsif params[:format]==nil
      
      if(!is_valid_url?)
        redirect_400
        return
      end
      page_show
    else
      file_show
      #render :nothing=>true and return
    end
  end

  #
  def search
    @pages=Page.where(readable_group_id:nil)
    #@pages=@pages.or(Page.where(readable_group_id:3))
    if current_user != nil
      current_user.usergroups.ids.each do |id|
        @pages=@pages.or(Page.where(readable_group_id:id.to_i))
      end
    end
    @pages.or(Page.where(readable_group_id:0,last_edit_user_id:current_user.id))
    if(params[:search]!="")
      searchstr= params[:search].split
      @pages=@pages.where("CONCAT(title,content) LIKE ?", "%"+searchstr.pop+"%")
      searchstr.each do |str|
        @pages=@pages.where("CONCAT(title,content) LIKE ?", "%"+str+"%")
      end
    else
      @pages=[]
    end
    renderleft "/"
    renderright
    render :file=>"pages/search"
  end

  def file_show
    parent,title=get_parent_title(params[:pages],0)
    filename=title+"."+params[:format]
    parent,title=get_parent_title(params[:pages],1)
    page=Page.where(parent:parent).find_by(title:title)
    file=nil
    file=page.uploadfiles.find_by(file_name:filename)
    if file!=nil && is_readable?(page)
      filedata = File.open(file.file_path,"r").read
      f = filename.split(/[.]/)
      if(f.size()==2&&(f[1]=="png"||f[1]=="jpg"||f[1]=="jpeg"||f[1]=='gif'))
        #send_data(filedata,filename:file.file_name,:disposition=>"inline")
        send_file(file.file_path,filename:file.file_name,:disposition=>"inline")
      else
        #send_data(filedata,filename:file.file_name,:disposition=>"attachment")
        send_file(file.file_path,filename:file.file_name,:disposition=>"attachment")
      end
    else
      redirect_400
      return
      #後でno imageでも返すようにする
    end
    #render :nothing=>true and return
  end
  def page_show
    force_trailing_slash
    @parent,@title=get_parent_title(params[:pages],0)
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
    renderright
    if @page != nil
      if is_editable?(@page)#編集権限を持つ
        @editable=true
      end
      if is_readable?(@page)
        @readable=true
        @content = CommonMarker.render_html(ERB::Util.html_escape(@page.content))
      else
        #@page =nil
        @content="アクセス権限がありません"
      end
    else
      @content = "未作成"
    end
  end
  def new
    if(!is_valid_url?)
      redirect_400
      return
    end
    if(!user_signed_in?)
      redirect_to @path
      return
    end
    @parent,@title=get_parent_title(params[:pages],0)
    @commongroup_editable="<option value='nil'>全員</option><option value='0'>自分のみ</option>"
    @commongroup_readable="<option value='nil'>全員</option><option value='0'>自分のみ</option>"
    @path=createpath(@parent,@title)
    @usergroups=Usergroup.all
    renderleft(@path[1,1000])
    renderright
    @page=Page.where(parent:@parent).find_by(title:@title)
    if @page!=nil
      if @path == ""
        @path = "/"
      end
      redirect_to(@path+"?edit=1")
    end
    @content=''
    @method='post'
  end
  def create
    if(!is_valid_url?)
      redirect_400
      return
    end
    @parent,@title=get_parent_title(params[:pages],0)
    page=Page.where(parent:@parent).find_by(title:@title)
    path = createpath(@parent,@title)
    if(!user_signed_in?)
      return
    end
    if(params[:content]!=nil)
      @parent,@title=get_parent_title(params[:pages],0)
      path = createpath(@parent,@title)
      page_create
    end
    if(params[:comment]!=nil)
      if(page!=nil && is_readable?(page))
        comment_create
      end
    end
    file_=params[:files]
    if file_!=nil && page!=nil&&is_editable?(page)
      #ファイルをアップできるのは編集者だけ
      file_create file_,page
    end
    redirect_to path
    return
  end
  def comment_create
    parent,title=get_parent_title(params[:pages],0)
    page=Page.where(parent:parent).find_by(title:title)
    if(page==nil)then return end
    comment=page.comments.create(comment:CommonMarker.render_html(ERB::Util.html_escape(params[:comment])))
    current_user.comments<<comment
    page.comments<<comment
  end
  def page_create
    last_edit_user_id=current_user.id
    parent,title=get_parent_title(params[:pages],0)
    path=createpath(parent,title)
    if(Page.where(parent:parent).find_by(title:title))
      update
      return
    end
    usergroups=Usergroup.all
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
    
    content = params[:content]#ERB::Util.html_escape(params[:content])
    if Page.where(parent:parent).find_by(title:title)==nil
      page=Page.create!(
        last_edit_user_id: last_edit_user_id,
        parent: parent,
        title:  title,
        content: content,
        readable_group_id: readable_group_id,
        editable_group_id: editable_group_id
      )
      history = Updatehistory.create(
        update_time: page.updated_at,
        content: page.content,
        user_id: page.last_edit_user_id,
      )
      page.updatehistorys<<history
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
    parent,title=get_parent_title(params[:pages],0)
    path=createpath(parent,title)
    path=path.gsub(/\.\./,"")
    output_dir=Rails.root.join('storage/files'+path,"")
    FileUtils.mkdir_p(output_dir,:mode => 755)
    output_path = Rails.root.join('storage/files'+path,file_param.original_filename)
    if(page.uploadfiles.find_by(file_name: file_param.original_filename)==nil)
      file = Uploadfile.create(
        file_name: file_param.original_filename,
        file_content_type: file_param.content_type,
        #file: file_.tempfile.open.read
        file_path: output_path
      )
      page.uploadfiles<<file
    else
      #page.uploadfiles.find_by(file_name: file_param.original_filename).update(file_name:file_param.original_filename)
    end
    File.open(output_path, 'w+b') do |fp|
      fp.write  file_param.read
    end
  end
  
  def edit
    @parent,@title=get_parent_title(params[:pages],0) 
    @path=createpath(@parent,@title)
    renderleft(@path[1,1000])
    renderright
    if(!is_valid_url?)
      redirect_400
      return
    end
    if(!user_signed_in?)
      redirect_to @path
      return
    end
    @page=Page.where(parent:@parent).find_by(title:@title)
    if @page==nil
      if @path == ""
        @path = "/"
      end
      redirect_to(@path+"?new=1")
      return
    end
    @commongroup_editable="<option value='nil'>全員</option><option value='0'>自分のみ</option>"
    @commongroup_readable="<option value='nil'>全員</option><option value='0'>自分のみ</option>"
    if(@page.editable_group_id == nil)
      @commongroup_editable="<option value='nil' selected='selected'>全員</option><option value='0'>自分のみ</option>"
    elsif @page.editable_group_id == 0
      @commongroup_editable="<option value='nil'>全員</option><option value='0' selected='selected'>自分のみ</option>"
    end
    if(@page.readable_group_id == nil)
      @commongroup_readable="<option value='nil' selected='selected'>全員</option><option value='0'>自分のみ</option>"
    elsif @page.readable_group_id == 0
      @commongroup_readable="<option value='nil'>全員</option><option value='0' selected='selected'>自分のみ</option>"
    end
    if !is_editable? @page
      redirect_to(@path)
      return
    end
    @usergroups=current_user.usergroups
    @content=@page.content
    @method='put'
    render :action=>'new'
  end
  def update
    if(!is_valid_url?)
      redirect_400
      return
    end
    @parent,@title=get_parent_title(params[:pages],0)
    @path=createpath(@parent,@title)
    
    @page=Page.where(parent:@parent).find_by(title:@title)
    if(!is_editable? @page)
      redirect_to @path
      return
    end
    #@content = ERB::Util.html_escape(params[:content])
    @content = params[:content]
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
      hist_user_id = @page.last_edit_user_id
      @page.update!(last_edit_user_id:current_user.id,content:@content,readable_group_id:readable_group_id,editable_group_id:editable_group_id)
      history = Updatehistory.create(
        update_time: @page.updated_at,
        content: @page.content,
        user_id: hist_user_id,
      )
      @page.updatehistorys<<history
      
      if(@page.updatehistorys.count>10) 
        @page.updatehistorys[0].delete
      end
    end
    redirect_to(@path)
  end
  def destroy
    if(!is_valid_url?)
      redirect_400
      return
    end
    parent,title=get_parent_title(params[:pages],0)
    path = createpath(parent,title)
    if !user_signed_in? 
      redirect_to path
      return
    end
    page=Page.where(parent:parent).find_by(title:title)
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
    parent,title=get_parent_title(params[:pages],0)
    page=Page.where(parent:parent).find_by(title:title)
    if page!=nil
      page.destroy
    end
  end
  def file_destroy
    parent,title=get_parent_title(params[:pages],0)
    page=Page.where(parent:parent).find_by(title:title)
    file = page.uploadfiles.find(params[:file_id].to_i)
    if file !=nil
      file.destroy
    end
  end
  def comment_destroy
    parent,title=get_parent_title(params[:pages],0)
    page=Page.where(parent:parent).find_by(title:title)
    comment = page.comments.find(params[:comment_id].to_i)
    if (comment !=nil&&(is_editable?(page)||comment.user_id==current_user.id))
      comment.destroy
    end
  end
  def renderleft str
    if str == nil || str == "/" then str = "" end
    if str.end_with? "/" then str.chop! end
    children = Page.where(parent:str).select(:parent,:title,:readable_group_id,:last_edit_user_id)
    @left_content=[]
    children.each do |child|
      if(!is_readable?(child))then next end
      path = createpath(child.parent,child.title)
      if(child.title=="")then next end
      @left_content+=[[child.title,path]]
    end
  end
  def renderright
    new100 = Page.limit(100).order("updated_at DESC").select(:parent,:title,:last_edit_user_id,:readable_group_id)
    @right_content=[]
    num = 50
    new100.each do |item|
      if(!is_readable?(item))then next end
      num-=1
      @right_content+=[createpath(item.parent,item.title)]
      if(num<=0)then break end
    end
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
      if(user_signed_in?&&(page.last_edit_user_id==nil||page.last_edit_user_id==current_user.id))
        return true
      else
        return false
      end
    end
    if !user_signed_in?
      return false
    end
    if current_user.admin
      return true
    end
    begin
      if Usergroup.find(page.editable_group_id).users.ids.include?(current_user.id)
        return true
      else
        return false
      end
    rescue =>e
      return true
    end
    return false
  end

  def is_readable? page
    if page.readable_group_id ==nil
      return true
    elsif page.readable_group_id == 0
      if(user_signed_in?&& page.last_edit_user_id==current_user.id)
        return true
      else
        return false
      end
    elsif !user_signed_in?
      return false
    end
    if current_user.admin
      return true
    end
    begin
      if Usergroup.find(page.readable_group_id).users.ids.include?(current_user.id)
        return true
      else
        return false
      end
    rescue =>e
      return true
    end
    return true
  end

  def is_valid_url?
    return true
  end
  def redirect_400
    #redirect_to "/400" #,{:status => 400}
    #raise ActionController::BadRequest,params[:pages]
    raise ActionController::RoutingError,params[:pages]#とりあえず404なげる（めんどい）
  end
end
