class Log < ApplicationRecord

  store :data , accessors: [ :msg ]

  belongs_to :money_burst

end
