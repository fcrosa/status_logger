class IntegrityLoggerService
  
  def self.log(attributes)
    IntegrityLog.create!(attributes)
  end

end