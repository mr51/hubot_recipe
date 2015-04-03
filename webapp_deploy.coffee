# Description
#   webapp deploy script.
#
#   ### 概要
#   PHPなどserverにファイルを設置するだけで動作するweb applicationのdeploy scriptです。
#   deploy 先は1台であることを前提にしています。複数台並列の環境は別の仕組みにしたほうが良い。
#   git pullには時間がかかる事があるためpull中本番実行中のソースに不整合が起きないように
#   本番展開は展開済みのソースに切り替える実装としています。
#   staging: 本番展開直前に動作を確認する環境   prod: 本番環境
#
#   ### Server構成
#   botサーバー <---- SSH ----> webapp_server (application server)
#   ※ ws1台の構成です。
#
#   ### ディレクトリ構成
#   /var/source/webapp       : 本番(prod)環境のドキュメントルート シンボリックリンクで webapp_0 or webapp_1 に向いている
#   /var/source/webapp_stg   : staging環境のドキュメントルート シンボリックリンクで webapp_0 or webapp_1 に向いている
#   /var/source/webapp_0     : 実際にソースを置く実体のディレクトリ
#   /var/source/webapp_1     : 実際にソースを置く実体のディレクトリ
#
# Commands:
#   deploy (dstaging|prod) - deploy webapp environment
child_process = require 'child_process'

module.exports = (robot) -> 
    robot.hear /^deploy (staging|prod)/i, (msg) ->
        command = ""

        switch msg.match[1]
            when "staging"
                command += "ssh www@webapp_server '"
                command +=     "prod_ref=`readlink -f /var/source/webapp`;"
                command +=     "stg_ref=`readlink -f /var/source/webapp_stg`;"
                command +=     "if test \"$prod_ref\" == \"$stg_ref\"; then "
                command +=         "if test \"$prod_ref\" == \"/var/source/webapp_0\";then "
                command +=             "stg_ref=/var/source/webapp_1;"
                command +=         "else "
                command +=             "stg_ref=/var/source/webapp_0;"
                command +=         "fi;"
                command +=         "echo \"stagingリンク張り替えます stg $stg_ref prod $prod_ref\";"
                command +=         "rm /var/source/webapp_stg;"
                command +=         "ln -s $stg_ref /var/source/webapp_stg;"
                command +=     "else "
                command +=         "echo \"stagingリンク張替えの必要なし\";"
                command +=     "fi;"
                command +=     "cd /var/source/webapp_stg;"
                command +=     "git pull origin master;"
                command += "';"
            when "prod"
                command += "ssh www@webapp_server '"
                command +=     "prod_ref=`readlink -f /var/source/webapp`;"
                command +=     "stg_ref=`readlink -f /var/source/webapp_stg`;"
                command +=     "if test \"$prod_ref\" == \"$stg_ref\"; then "
                command +=         "echo \"既に本番展開済みです。\";"
                command +=     "else "
                command +=         "echo \"stagingを本番に昇格します。\";"
                command +=         "rm /var/source/webapp;"
                command +=         "ln -s $stg_ref /var/source/webapp;"
                command +=     "fi;"
                command += "';"
            else
                command = "echo \"まだこの環境のdeployコマンドは設定されていません\""

        msg.send "deploy #{msg.match[1]} 実行します。\n===================================\n"
        command += "echo \"===================================\";"
        command += "echo \"deploy #{msg.match[1]} を実行しました。\";"
        child_process.exec command, (error, stdout, stderr) ->
            msg.send stderr
            msg.send stdout
