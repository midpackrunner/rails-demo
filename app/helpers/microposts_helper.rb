module MicropostsHelper

  def wrap(content)
    sanitize(raw(content.split.map{ |s| evaluate_and_wrap_string(s) }.join(' ')))
  end

private
    def evaluate_and_wrap_string(text)
      regex = /(.*)(href=["\']+.*["\']+)(.*)/
      if text =~ regex
        regex.match(text)
        [wrap_long_string($1), $2, wrap_long_string($3)].join()
      else
        wrap_long_string(text)
      end
    end
    
    def wrap_long_string(text, max_width = 30)
      zero_width_space = "&#8203;"
      regex = /.{1,#{max_width}}/
      (text.length < max_width) ? text :
                                  text.scan(regex).join(zero_width_space)
    end
end