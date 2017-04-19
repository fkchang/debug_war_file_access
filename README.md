# Problem
- Purpose of this part of the original app is to tail, view, download, delete log files
- Can logo to a file, do file operations in develpoment/rackup mode
- Can log to a file, do file read, tail filename, sometimes download it (unable to duplicate), but the file can't be seen via shell, and/or dissappears after quicking app run in production mode as warfile
- Feels like production mode is in sandbox, or something is not completely flushed, i.e. logging to a file is seen via Dir[], File.read, shelling out to tail, sometimes downloadable via sinatra's send_file (not consistent), but only w/in the app. It can't been seen outside of the app, and doesn't get flushed when app is killed
- Above works fine via rackup in both dev and production mode

# In development mode via rackup steps
- run in development mode via rackup
- hit http://localhost:9292/logs
- you'll see development.log as a file (obtained with ```Dir["#{LOG_PREFIX}/*"]```)

- hit the tail button a few times, see the log grow, you can check from the shell
- development.log file content was created and stays

# In production mode via war file steps
- build war, ```warble```, ```rake war``` both work
- run war file ```java -jar pms_server.war```
- hit http://localhost:8080/logs
- you'll see the production.log entry as well (obtained with ```Dir["#{LOG_PREFIX}/*"]```
- click tail button a few times, see entries loaded, in my app, you could download the file with the contents, in this isolated version, it says it's not there - not sure why not now
- ctl-c command to stop
- no production.log file



