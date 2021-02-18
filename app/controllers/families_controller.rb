# encoding : utf-8


class FamiliesController < BeautifulController

  before_action :load_family, :only => [:show, :edit, :update, :destroy]

  # Uncomment for check abilities with CanCan
  #authorize_resource

  def index
    session['fields'] ||= {}
    session['fields']['family'] ||= (Family.columns.map(&:name) - ["id"])[0..4]
    do_select_fields('family')
    do_sort_and_paginate('family')
    
    @q = Family.ransack(
      params[:q]
    )

    @family_scope = @q.result(
      :distinct => true
    ).sorting(
      params[:sorting]
    )
    
    @family_scope_for_scope = @family_scope.dup
    
    unless params[:scope].blank?
      @family_scope = @family_scope.send(params[:scope])
    end
    
    @families = @family_scope.paginate(
      :page => params[:page],
      :per_page => 20
    ).to_a

    respond_to do |format|
      format.html{
        render
      }
      format.json{
        render :json => @family_scope.to_json(methods: :caption)
      }
      format.csv{
        require 'csv'
        csvstr = CSV.generate do |csv|
          csv << Family.attribute_names
          @family_scope.to_a.each{ |o|
            csv << Family.attribute_names.map{ |a| o[a] }
          }
        end 
        render :plain => csvstr
      }
      format.xml{ 
        render :xml => @family_scope.to_a
      }             
      format.pdf{
        pdfcontent = PdfReport.new.to_pdf(Family,@family_scope)
        send_data pdfcontent
      }
    end
  end

  def show
    respond_to do |format|
      format.html{
        render
      }
      format.json { render :json => @family }
    end
  end

  def new
    @family = Family.new

    respond_to do |format|
      format.html{
        render
      }
      format.json { render :json => @family }
    end
  end

  def edit
    
  end

  def create
    @family = Family.new(params_for_model)

    respond_to do |format|
      if @family.save
        format.html {
          if params[:mass_inserting] then
            redirect_to families_path(:mass_inserting => true)
          else
            redirect_to family_path(@family), :flash => { :notice => t(:create_success, :model => "family") }
          end
        }
        format.json { render :json => @family, :status => :created, :location => @family }
      else
        format.html {
          if params[:mass_inserting] then
            redirect_to families_path(:mass_inserting => true), :flash => { :error => "#{t(:error, default: "Error")} : #{@family.errors.full_messages.join(", ")}" }
          else
            render :action => "new"
          end
        }
        format.json { render :json => @family.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update

    respond_to do |format|
      if @family.update(params_for_model)
        format.html { redirect_to family_path(@family), :flash => { :notice => t(:update_success, :model => "family") }}
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @family.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @family.destroy

    respond_to do |format|
      format.html { redirect_to families_url }
      format.json { head :ok }
    end
  end

  def batch
    attr_or_method, value = params[:actionprocess].split(".")

    @families = []    
    
    Family.transaction do
      if params[:checkallelt] == "all" then
        # Selected with filter and search
        do_sort_and_paginate(:family)

        @families = Family.ransack(
          session['search']['family']
        ).result(
          :distinct => true
        )
      else
        # Selected elements
        @families = Family.find(params[:ids].to_a)
      end

      @families.each{ |family|
        if not Family.columns_hash[attr_or_method].nil? and
               Family.columns_hash[attr_or_method].type == :boolean then
         family.update_attribute(attr_or_method, boolean(value))
         family.save
        else
          case attr_or_method
          # Set here your own batch processing
          # family.save
          when "destroy" then
            family.destroy
          when "touch" then
            family.touch
          end
        end
      }
    end
    
    redirect_to families_url
  end

  def treeview

  end

  def treeview_update
    modelclass = Family
    foreignkey = :family_id


    if update_treeview(modelclass, foreignkey)
      head :ok
    else
      head :internal_server_error
    end
  end
  
  private 
  
  def load_family
    @family = Family.find(params[:id])
  end

  def params_for_model
    params.require(:family).permit(Family.permitted_attributes)
  end
end

