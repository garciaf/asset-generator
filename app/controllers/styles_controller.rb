class StylesController < ApplicationController
  def index
    @styles = Style.all
  end

  def show
    @style = Style.find(params[:id])
  end

  def new
    @style = Style.new
  end

  def create
    @style = Style.new(style_params)

    if @style.save
      redirect_to styles_path, notice: "Style was successfully created."
    else
      render :new
    end
  end

  def edit
    @style = Style.find(params[:id])
  end

  def update
    @style = Style.find(params[:id])

    if @style.update(style_params)
      redirect_to @style, notice: "Style was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @style = Style.find(params[:id])
    @style.destroy
    redirect_to styles_url, notice: "Style was successfully deleted."
  end

  private

  def style_params
    params.require(:style).permit(:title, :prompt)
  end
end
