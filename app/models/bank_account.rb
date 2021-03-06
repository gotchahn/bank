class BankAccount < ActiveRecord::Base
  belongs_to :client
  has_one :debit_card
  has_many :transactions

  validates_presence_of :currency
  validates_numericality_of :balance, greater_than_or_equal_to: 0
  before_save :set_rate_segun_tipo

  default_scope { order(created_at: :desc) }
  scope :normales, -> { where(account_type: "Normal") }
  scope :vips, -> { where(account_type: "Vip") }
  scope :plazos, -> { where(account_type: "Plazo") }
  scope :cheques, -> { where(account_type: "Cheques") }

  scope :by_currency, -> (currency) {where(currency: currency)}

  accepts_nested_attributes_for :debit_card

  def depositar(monto)
    self.balance = self.balance + monto
  end

  def retirar(monto)
    self.balance = self.balance - monto
  end

  def self.generar_intereses
    collection = all
    collection.each do |account|
      amount = account.balance * 0.05
      account.balance = account.balance + amount
      #Generar una transaccion
      account.transactions.create(label: "Interes", amount: amount)
      account.save
    end
  end

  def rate_decorado
    "#{rate*100}%"
  end

  def balance_decorado
    "$ %.2f" % balance
  end

  def set_rate_segun_tipo
    case self.account_type
    when "Normal"
      self.rate = 0.02
    when "Vip"
      self.rate = 0.05
    when "Plazo"
      self.rate = 0.1
    else
      self.rate = 0;
    end
  end
end
