require "csv"

class ImportsController < ApplicationController
  def create
    file = params[:file]
    unless file
      redirect_to root_path, alert: "Please select a CSV file."
      return
    end

    csv_text = file.read.force_encoding("UTF-8")
    csv = CSV.parse(csv_text, headers: true)

    headers = csv.headers.map { |h| h.to_s.strip.downcase }
    email_col = csv.headers.find { |h| h.to_s.strip.downcase == "email" }
    id_col = csv.headers.find { |h| %w[id id_number number].include?(h.to_s.strip.downcase) }

    unless id_col
      redirect_to root_path, alert: "CSV must have a column named 'id', 'id_number', or 'number'."
      return
    end

    rows = []
    now = Time.current

    csv.each do |row|
      id_number = row[id_col].to_s.strip
      next unless id_number.match?(/\A\d{6}\z/)

      email = email_col ? row[email_col].to_s.strip.presence : nil
      rows << { id_number: id_number, email: email, created_at: now, updated_at: now }
    end

    if rows.empty?
      redirect_to root_path, alert: "No valid rows found in CSV."
      return
    end

    result = Entry.insert_all(rows, unique_by: :id_number)
    inserted = result.length
    skipped = rows.length - inserted

    msg = "Imported #{inserted} entr#{inserted == 1 ? 'y' : 'ies'}"
    msg += ", skipped #{skipped} duplicate#{skipped == 1 ? '' : 's'}" if skipped > 0

    redirect_to root_path, notice: msg
  end
end
