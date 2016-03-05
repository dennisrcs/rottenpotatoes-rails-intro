class Movie < ActiveRecord::Base
  @ratings = ['G','PG','PG-13','NC-17','R']
  
  def self.ratings
    return @ratings
  end

  def self.is_checked_init
    @is_checked = Hash.new
    @ratings.each do |x|
      @is_checked[x] = true
    end
    return @is_checked
  end

  def self.update_is_checked(keys)
    @ratings.each do |x|
      if keys.include?(x)
        @is_checked[x] = true
      else
        @is_checked[x] = false
      end
    end
    return @is_checked
  end

end
