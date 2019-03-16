class CommentsController < PagesController
  def create
    get_parent_title(params[:pages],0)
    com=params[:comment]
    comment=Comment.create!(comment: com)
    comment.user<<current_user
  end
  def delete

  end
end
