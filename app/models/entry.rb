class Entry < ApplicationRecord
  validates :id_number, presence: true, uniqueness: true,
                        format: { with: /\A\d{6}\z/, message: "must be exactly 6 digits" }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email" },
                    allow_blank: true

  def link
    "https://www.g2.com/products/g2-seller-solutions/take_survey?utm_source=#{id_number}"
  end

  def self.any_emails?
    where.not(email: [nil, ""]).exists?
  end
end
