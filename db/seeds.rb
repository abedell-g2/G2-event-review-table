DOMAINS = %w[gmail.com yahoo.com outlook.com company.com acme.io salesforce.com hubspot.com].freeze
FIRST_NAMES = %w[Alice Bob Carol Dave Elena Frank Grace Henry Isabel James Karen Leo Maya Noah Olivia].freeze
LAST_NAMES = %w[Smith Johnson Williams Brown Jones Garcia Martinez Davis Wilson Anderson Taylor Moore Jackson Martin Lee].freeze

used_ids = Entry.pluck(:id_number).to_set
inserted = 0

100.times do
  id_number = nil
  10.times do
    candidate = format("%06d", rand(100_000..999_999))
    unless used_ids.include?(candidate)
      id_number = candidate
      used_ids << candidate
      break
    end
  end
  next unless id_number

  first = FIRST_NAMES.sample
  last  = LAST_NAMES.sample
  email = "#{first.downcase}.#{last.downcase}#{rand(10..99)}@#{DOMAINS.sample}"

  Entry.find_or_create_by!(id_number: id_number) do |e|
    e.email = email
  end
  inserted += 1
end

puts "Seeded #{inserted} entries."
