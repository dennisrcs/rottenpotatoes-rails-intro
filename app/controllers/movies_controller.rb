class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings
    
    # fill is_checked hash 
    if @is_checked == nil
      @is_checked = Movie.is_checked_init
    end

    @movies = Movie.all
    
    # update ratings in session
    if params.has_key?(:ratings)
      session[:ratings] = params[:ratings]
    end
    
    # updating sort_by params in session
    if params.has_key?(:sort_by)
      session[:sort_by] = params[:sort_by]
    end

    # compare params and session and redirect if necessary
    check_params_redirect()

    # if there are ratings key, then filter movies
    if session.has_key?(:ratings)
      filter_movies(session[:ratings])
    end

    # if there is a sort_by key, then sort movies
    if session.has_key?(:sort_by)
      sort_movies(session[:sort_by])
    end
  end

  # if session and params are different, fill params and redirect
  def check_params_redirect
    if (session.has_key?(:ratings) ^ params.has_key?(:ratings)) ||
          (session.has_key?(:sort_by) ^ params.has_key?(:sort_by))
      # filling data from session
      parameters = Hash.new
      parameters[:ratings] = session[:ratings]
      parameters[:sort_by] = session[:sort_by]
      
      # forces flash to keep message
      flash.keep
  
      # redirect with the proper params, to keep RESTfulness
      redirect_to movies_path(parameters)
    end
  end

  # filter movings according to ratings parameter
  def filter_movies(ratings)
    # update is_checked hash
    @is_checked = Movie.update_is_checked(session[:ratings])
      
    # get keys and filter subset
    keys = session[:ratings].keys
    @movies = Movie.where(rating: keys)
  end

  # sort movies according to sort_by param
  def sort_movies(sort_by)
     # setting proper class
      if sort_by == "title"
        @movies = @movies.sort {|a, b| a.title <=> b.title}
        @hilite_title = "hilite"
      else
        @movies = @movies.sort {|a, b| a.release_date <=> b.release_date}
        @hilite_release_date = "hilite"
      end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
