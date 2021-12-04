# Name
bitbucket_metrics_checker

# About
Bitbucketの指定したワークスペースに対して、ユーザごとのプルリクエスト一覧をCSVに出力します。
BitbucketのAPIの認証はすこしわかりにくいのでほかのデータをとりたいときに取り組みやすくするためのひな型です。

# Installation

```bash
bundle install
```

# Usage

１．Bitbucketの以下ページにてapp passwordを設定し、ユーザ名とworkspaceを .envに記載してください

https://bitbucket.org/account/settings/app-passwords/

２．下記コマンドを実行してください

```bash
ruby checker.rb
```

# Note
Bitbucketでは10件ずつデータ取得できます。あいだに2秒sleepをいれているのでそれなりに時間がかかるのでご注意ください

# Author

* daaaaaai

