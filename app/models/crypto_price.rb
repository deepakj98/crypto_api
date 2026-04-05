class CryptoPrice < ApplicationRecord
	validates :symbol, presence: true, uniqueness: true
end
