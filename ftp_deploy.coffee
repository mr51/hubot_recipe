# Description
#   web site ftp deploy script.
#   ### 事前準備
#   /home/bot/website/ に対象のgit repositoryをgit clone
#   ### 処理内容
#   /home/bot/website/htdocs/ をFTPでカレント直下htdocsフォルダにsync
#
# Commands:
#   deploy website - deploy web page  (ftp)
child_process = require 'child_process'

module.exports = (robot) -> 
    robot.hear /^deploy website/i, (msg) ->
        command = "cd /home/bot/website/;git pull origin master;lftp -u <<ftpaccount>>,<<ftppass>> <<ftphostname>> -e \"mirror -R ./htdocs htdocs ;exit;\""

        msg.send "deploy website 実行します。\n===================================\n"
        command += ";echo \"==================================\n\""
        command += ":echo \"deploy website を実行しました。\";"
        child_process.exec command, (error, stdout, stderr) ->
            msg.send stderr
            msg.send stdout
