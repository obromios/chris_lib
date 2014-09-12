module DateExt
  # To format a date, use <tt>date.charmians_format</tt>
  # on any Date object.
  #
  #   class Date
  #     charmians_format
  #   end
  #
  # If using a DateTime object, need to convert to date i.e. <tt>datetime.to_date.charmians_format
  Date.class_eval do
    def us_format
      "#{strftime('%B')} #{day.to_s}, #{year.to_s}"
    end
    def us_format_with_weekday
    	"#{strftime('%A')}, #{strftime('%B')} #{day.to_s}, #{year.to_s}"
    end
    def charmians_format
    	d=cardinalation(day)
    	"#{strftime('%A')}, #{d} #{strftime('%B')}, #{year.to_s}"
    end
    def charmians_format_sup
    	d=cardinalation(day,true)
    	"#{strftime('%A')}, #{d} #{strftime('%B')}, #{year.to_s}"
    end
    private
    def cardinalation(day,html_sup=false)
    	s=case day
    	when 1,21,31
    		'st'
    	when 2,22
    		'nd'
    	when 3,23
    		'rd'
    	else
    		'th'
    	end
    	s="<sup>#{s}</sup>" if html_sup
    	"#{day}#{s}"
    end
  end
end


