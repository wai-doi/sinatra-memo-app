# Usage
```
$ bundle install --path vendor/bundle

$ bundle exec ruby myapp.rb
```
http://localhost:4567/

## DBのファイルは残しつつ差分がGitに反映されないようにする
自分のワークツリーだけ有効
```
$ git update-index --skip-worktree db/*
```
