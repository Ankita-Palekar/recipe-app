class Task
  include Delayed::RecurringJob
  run_every 10.minutes
  # run_at '5:30pm'
  timezone 'Asia/Kolkata'
  queue 'slow-jobs'
  def perform
  	Recipe.delete_unwanted_recipe_images
    # Photo.where(:recipe_id => nil).destroy_all
  end
end


