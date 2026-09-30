class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # Weakest role first so the column default is the least privileged.
  enum :role, { customer_custodian: 0, customer: 1, instructor: 2, admin: 3 }

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true

  def role_in?(roles)
    roles.include?(role.to_sym)
  end
end
