# == Schema Information
#
# Table name: customers
#
#  id         :bigint           not null, primary key
#  full_name  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Customer < ApplicationRecord
  has_one :account, dependent: :destroy

  has_many :credit_cards, through: :account

  accepts_nested_attributes_for :account

  validates :full_name, presence: true, length: { in: 2..26 }
end
