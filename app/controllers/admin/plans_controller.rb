# frozen_string_literal: true

module Admin
  class PlansController < ::ApplicationController
    before_action :set_plan, only: %i[edit update destroy]
    def index
      @plans = Plan.all
    end

    def new
      @plan = Plan.new
    end

    def create
      @plan = Plan.new(plan_params)
      respond_to do |format|
        if @plan.save
          format.html do
            redirect_to admin_plans_path,
                        notice: 'Plan was successfully created.'
          end
          format.json { render :show, status: :created, location: @plan }
        else
          format.html { render :new }
          format.json do
            render json: @plan.errors, status: :unprocessable_entity
          end
        end
      end
    end

    def edit; end

    def update
      respond_to do |format|
        if @plan.update(plan_params)
          format.html do
            redirect_to admin_plans_path,
                        notice: 'Plan was successfully updated.'
          end
          format.json { json_response(@plan, :updated) }
        else
          format.html { render :edit }
          format.json do
            render json: { errors: @plan.errors, status: :unprocessable_entity }
          end
        end
      end
    end

    def destroy
      @plan.destroy
      respond_to do |format|
        format.html do
          redirect_to admin_plans_url,
                      notice: 'Plan was successfully destroyed.'
        end
        format.json { head :no_content }
      end
    end

    private

    def set_plan
      @plan = Plan.find(params[:id])
    end

    def plan_params
      params.require(:plan).permit(:name, :country_limit)
    end
  end
end
