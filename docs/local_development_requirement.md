#本地项目需要跑 `memcached`, `elasticsearch`

##Mac开发ElasticSearch配置

brew install elasticsearch

安装完后,按照文档可以设置开机启动

> ln -sfv /usr/local/opt/elasticsearch/*.plist ~/Library/LaunchAgents
> launchctl load ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch.plist

然后跑以下命令启动
> elasticsearch --config=/usr/local/opt/elasticsearch/config/elasticsearch.yml
