desc 'Removes war file - warble seems to have a problem w/o this on my laptop'
task :clean do 
  puts "Removing war"
  FileUtils.rm 'pms_server.war'
end

desc 'makes war file'
task :war do 
  sh 'warble'
end

desc 'makes war and copies to dropbox'
task :default => [:clean, :war]
