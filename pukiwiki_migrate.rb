$controller = PagesController.new
$content_dir = "./pukiwiki/content/"
$file_dir="./pukiwiki/static/"
$storage_dir="./storage/files/"
$err=""
$err_f=[]
def migrate_pukiwiki
  readdir $content_dir
  readfiledir $file_dir
  puts $err_f
  File.open("./pukiwiki_migrate.log","w") do |file|
      file.puts $err +"\n"
  end
end
def readdir dir_str
  dir = Dir.open(dir_str)
  dir.children.each do |child|
    child_path = dir.path+"/"+child
    if FileTest.directory? child_path
      readdir child_path
    elsif FileTest.file? child_path
      readcontent child_path
    end
  end
  return nil
end
def readcontent path
  path_= path[$content_dir.length, path.length]
  path_=path_.split("/")
  path_.pop
  path_ = path_.join("/")
  parent,title= $controller.get_parent_title path_,0
  if(parent.length!=0)
    parent=parent[1,parent.length]
  end
  str=File.open(path).read
  begin
    if(Page.where(parent:parent).find_by(title:title)==nil)
      Page.create(parent:parent,title:title,last_edit_user_id:0,content:str)
    end
  rescue => e
    puts e
    $err_f += [path_]
    $err +=e.to_s
  end
end
def readfiledir dir_str
  dir = Dir.open(dir_str)
  dir.children.each do |child|
    child_path = dir.path+"/"+child
    if FileTest.directory? child_path
      readfiledir child_path
    elsif FileTest.file? child_path
      readfile child_path
    end
  end
  return nil
end
def readfile path
  path_= path[$file_dir.length, path.length]
  path_=path_.split("/")
  file_name=path_.pop
  path_ = path_.join("/")
  parent,title= $controller.get_parent_title path_,0
  if(parent.length!=0)
    parent=parent[1,parent.length]
  end
  #str=File.open(path).read
  begin
    page =Page.where(parent:parent).find_by(title:title)
    if(page!=nil)
      FileUtils.mkpath($storage_dir+path_)
      FileUtils.cp_r(path,$storage_dir+path_+"/"+file_name)
      if( page.uploadfiles.find_by(file_name:file_name)==nil)
        file = Uploadfile.create(file_name:file_name,file_path:path_+"/"+file_name)
        puts $storage_dir+path_+file_name
        page.uploadfiles<<file
      end
    end
  rescue => e
    puts e
    $err_f += [path_]
    $err +=e.to_s
  end
end
