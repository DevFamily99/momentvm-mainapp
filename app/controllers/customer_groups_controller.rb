class CustomerGroupsController < ApplicationController
  before_action :set_customer_group, only: [:show, :edit, :update, :destroy]

  def index
    @customer_groups = CustomerGroup.all
  end

  def show
  end


  def new
    @customer_group = CustomerGroup.new
  end

  def edit
  end

  def create
    @customer_group = CustomerGroup.new(customer_group_params)

    respond_to do |format|
      if @customer_group.save
        format.html { redirect_to @customer_group, notice: 'Customer group was successfully created.' }
        format.json { render :show, status: :created, location: @customer_group }
      else
        format.html { render :new }
        format.json { render json: @customer_group.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @customer_group.update(customer_group_params)
        format.html { redirect_to @customer_group, notice: 'Customer group was successfully updated.' }
        format.json { render :show, status: :ok, location: @customer_group }
      else
        format.html { render :edit }
        format.json { render json: @customer_group.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @customer_group.destroy
    respond_to do |format|
      format.html { redirect_to customer_groups_url, notice: 'Customer group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer_group
      @customer_group = CustomerGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_group_params
      params.require(:customer_group).permit(:name)
    end
end
