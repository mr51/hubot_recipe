# Description
#   website s3 deploy script.
#   ### 事前準備
#   - /home/bot/website/ に対象のgit repositoryをgit clone
#   - s3cmdの初期設定を実施
#
#   ### 処理内容
#   - /home/bot/website/htdocs/ をs3cmdでbacket直下にsync
#   - cssのcontent-typeが稀におかしくなるので、content-typeを修正
#
# Commands:
#   deploy s3website - deploy web page (s3)
child_process = require 'child_process'

module.exports = (robot) -> 
    robot.hear /^deploy s3website/i, (msg) ->
        command  = "cd /home/bot/website;git pull origin master;s3cmd sync /home/bot/website/htdocs/ s3://BACKET_NAME/;"
        command += "cd /home/bot/website/htdocs;find . -name \"*.css\" |sed 's/^\\.\\///'|awk '{system(\"s3cmd --add-header=Content-Type:text/css modify s3://BACKET_NAME/\"$1)}';"

        msg.send "deploy website 実行します。\n===================================\n"
        command += ";echo \"==================================\n\""
        command += ";echo \"deploy website を実行しました。\";"
        child_process.exec command, (error, stdout, stderr) ->
            msg.send stderr
            msg.send stdout
