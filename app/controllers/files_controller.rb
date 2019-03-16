class FilesController < ApplicationController
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
  def show
    get_parent_title(params[:pages],0)
    page =Page.where(parent:@parent).find_by(title:@title)
    filename=params[:file]
    format=params[:format]
    if(filename==nil)
      filename=""
    end
    if(format!=nil)
      filename=filename+"."+format
    end
    file=nil
    file = page.uploadfiles.find_by(file_name: filename)
    
    if file !=nil
      send_data(file.file ,filename: file.file_name,:disposition=>"inline")
    end
  end
end
