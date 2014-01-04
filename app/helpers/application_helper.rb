module ApplicationHelper
  
  def site_title( page_title = '', separator = '|' )
    base_title = 'Rails Demo'
    if page_title.empty? 
      base_title
    else
      separator = separator.blank? ? '|' : separator
      "#{page_title} #{separator} #{base_title}"
    end
  end
  
end
