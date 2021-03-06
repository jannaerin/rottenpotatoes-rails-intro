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
    @all_ratings = Movie.all_ratings
    @redirect = false
    
    if params[:ratings]
      @ratings = params[:ratings]
      session[:ratings] = params[:ratings]
    elsif session[:ratings]
      @ratings = session[:ratings]
      params[:ratings] = @ratings
      @redirect = true
    else
      @ratings = Hash[*@all_ratings.map {|k| [k, 1]}.flatten]
    end
      
    if params[:sort]
      @sort = params[:sort]
      session[:sort] = params[:sort]
    elsif session[:sort]
      @sort = session[:sort]
      params[:sort] = @sort
      @redirect = true
    else
      @sort = nil
    end
    
    if @redirect == true
      flash.keep
      redirect_to movies_path(:sort => @sort, :ratings => @ratings)
      return
    end
    
    if @sort == 'title'
      @movies = Movie.where(:rating => @ratings.keys).order('title')
      @title_header = 'hilite'
    elsif @sort == 'release_date'
      @movies = Movie.where(:rating => @ratings.keys).order('release_date')
      @release_date_header = 'hilite'
    else
      @movies = Movie.where(:rating => @ratings.keys)
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