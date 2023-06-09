class PublishingLocalesController < ApplicationController
  before_action :set_publishing_locale, only: [:show, :edit, :update, :destroy]

  # GET /publishing_locales
  # GET /publishing_locales.json
  def index
    @publishing_locales = PublishingLocale.all
  end

  # GET /publishing_locales/1
  # GET /publishing_locales/1.json
  def show
  end

  # GET /publishing_locales/new
  def new
    @publishing_locale = PublishingLocale.new
  end

  # GET /publishing_locales/1/edit
  def edit
  end

  # POST /publishing_locales
  # POST /publishing_locales.json
  def create
    @publishing_locale = PublishingLocale.new(publishing_locale_params)

    respond_to do |format|
      if @publishing_locale.save
        format.html { redirect_to @publishing_locale, notice: 'Publishing locale was successfully created.' }
        format.json { render :show, status: :created, location: @publishing_locale }
      else
        format.html { render :new }
        format.json { render json: @publishing_locale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /publishing_locales/1
  # PATCH/PUT /publishing_locales/1.json
  def update
    respond_to do |format|
      if @publishing_locale.update(publishing_locale_params)
        format.html { redirect_to @publishing_locale, notice: 'Publishing locale was successfully updated.' }
        format.json { render :show, status: :ok, location: @publishing_locale }
      else
        format.html { render :edit }
        format.json { render json: @publishing_locale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /publishing_locales/1
  # DELETE /publishing_locales/1.json
  def destroy
    @publishing_locale.destroy
    respond_to do |format|
      format.html { redirect_to publishing_locales_url, notice: 'Publishing locale was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_publishing_locale
      @publishing_locale = PublishingLocale.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def publishing_locale_params
      params.fetch(:publishing_locale, {})
    end
end
