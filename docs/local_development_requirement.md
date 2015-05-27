#本地项目需要跑 `memcached`, `elasticsearch`

##Mac开发ElasticSearch配置

brew install elasticsearch

安装完后,按照文档可以设置开机启动

> ln -sfv /usr/local/opt/elasticsearch/*.plist ~/Library/LaunchAgents
> launchctl load ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch.plist

然后跑以下命令启动
> elasticsearch --config=/usr/local/opt/elasticsearch/config/elasticsearch.yml

##添加Model到elasticsearch中搜索, 例如把Star搜索加入
> RAILS_ENV=development bundle exec rake environment elasticsearch:import:model CLASS='Star' FORCE=y

##所有model添加到elasticsearch
> rake environment elasticsearch:import:all

##Sidekiq
bundle exec sidekiq

##错误邮件账户
hoishow-error@bestapp.us
hoishow!@#456

----

##利用cpu多核提高测试速度
###配置步骤
Gemfile development组加入
```
gem 'parallel_tests'
gem 'zeus-parallel_tests'
```
修改config/database.yml
```
test:
  database: hoishow_test<%= ENV['TEST_ENV_NUMBER'] %>
```
创建数据库
```
rake parallel:create
```
复制schema（有新的migration需再跑一次这句）
```
rake parallel:prepare
```
创建自定义zeus plan
```
zeus-parallel_tests init
```
修改zeus.json
```
 {
  "command": "ruby -rubygems -r./custom_plan -eZeus.go",

  "plan": {
    "boot": {
      "default_bundle": {
        "development_environment": {
          "prerake": {"rake": []},
          "runner": ["r"],
          "console": ["c"],
          "server": ["s"],
          "generate": ["g"],
          "destroy": ["d"],
          "dbconsole": [],
          "parallel_rspec": []
        },
        "test_environment": {
          "test_helper": {
            "test": ["rspec", "testrb"],
            "parallel_rspec_worker": []
          }
        }
      }
    }
  }
} 
```
###跑多核测试
```
zeus parallel_rspec spec
```
