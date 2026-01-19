namespace :dev do
  desc "Toggle using rack-mini-profiler"
  task :profiler do
    file_path = Rails.root.join("tmp/profiling-dev.txt")

    if File.exist?(file_path)
      File.delete(file_path)
      puts "Rack mini profiler disabled for development mode."
    else
      File.write(file_path, "")
      puts "Rack mini profiler enabled for development mode."
    end
  end
end
