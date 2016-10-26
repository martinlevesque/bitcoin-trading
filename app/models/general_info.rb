class GeneralInfo < ApplicationRecord

  store :data , accessors: [ :fees, :last_fees_check ]

  def self.get_fees(api)

    general_infos = GeneralInfo.last

    if general_infos.fees.blank? || (Time.now - general_infos.last_fees_check.to_time >= 3600)
      general_infos.fees = api.fees
      general_infos.last_fees_check = Time.now
      general_infos.save
    end

    return general_infos.fees
  end

end
