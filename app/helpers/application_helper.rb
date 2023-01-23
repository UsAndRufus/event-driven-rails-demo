module ApplicationHelper
  def use_page_as(user)
    return request.path if user.nil?

    url_for controller: params[:controller], action: params[:action], user: user
  end
end
