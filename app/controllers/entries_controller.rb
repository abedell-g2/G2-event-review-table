class EntriesController < ApplicationController
  before_action :set_entry, only: [:update, :destroy]

  def index
    @show_email_col = Entry.any_emails?
    if params[:search].present?
      q = "%#{params[:search]}%"
      @entries = Entry.where("email ILIKE ? OR id_number ILIKE ?", q, q).order(:id_number)
      @paginated = false
    else
      @entries = Entry.order(:id_number).page(params[:page]).per(50)
      @paginated = true
    end
    @entry = Entry.new
  end

  def create
    @entry = Entry.new(entry_params)
    @show_email_col = Entry.any_emails?
    if @entry.save
      @show_email_col = Entry.any_emails?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend("entries-tbody", partial: "entries/entry", locals: { entry: @entry, show_email_col: @show_email_col }),
            turbo_stream.replace("entry-form", partial: "entries/form", locals: { entry: Entry.new, show_email_col: @show_email_col })
          ]
        end
        format.html { redirect_to root_path, notice: "Entry created." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("entry-form", partial: "entries/form", locals: { entry: @entry, show_email_col: @show_email_col })
        end
        format.html { redirect_to root_path, alert: @entry.errors.full_messages.join(", ") }
      end
    end
  end

  def update
    @show_email_col = Entry.any_emails?
    if @entry.update(entry_params)
      @show_email_col = Entry.any_emails?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("entry-#{@entry.id}", partial: "entries/entry", locals: { entry: @entry, show_email_col: @show_email_col })
        end
        format.html { redirect_to root_path }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("entry-#{@entry.id}", partial: "entries/entry_edit", locals: { entry: @entry, show_email_col: @show_email_col })
        end
        format.html { redirect_to root_path, alert: @entry.errors.full_messages.join(", ") }
      end
    end
  end

  def destroy
    @entry.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("entry-#{@entry.id}") }
      format.html { redirect_to root_path }
    end
  end

  private

  def set_entry
    @entry = Entry.find(params[:id])
  end

  def entry_params
    params.require(:entry).permit(:email, :id_number)
  end
end
