namespace :viagogo do
  task :data => :environment do
    ViagogoDataToHoishow::Service.data_to_hoishow
  end

end
