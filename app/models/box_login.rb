class BoxLogin < ActiveRecord::Base
  serialize :details

  def access_token
    details.with_indifferent_access[:token]
  end

  def refresh_token
    details.with_indifferent_access[:refresh_token]
  end

  def refresh_token=(token)
    self.details.with_indifferent_access[:refresh_token] = token
    save
  end
end
