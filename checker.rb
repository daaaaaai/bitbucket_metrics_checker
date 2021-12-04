require 'bundler/setup'
require 'dotenv'
require 'net/http'
require 'uri'
require 'json'
require 'time'
require "csv"

Dotenv.load

# bitbucketAPIに指定のURLでアクセスしJSONを取得する
# https://developer.atlassian.com/cloud/bitbucket/rest/intro/
def get_bitbucket(url: "")
  uri = URI.parse(url)
  request = Net::HTTP::Get.new(uri)
  request.basic_auth(ENV['username'], ENV['app_password'])

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

  return JSON.parse(response.body)
end

# ページャに沿って再帰的にレポジトリ名一覧を取得する
# ※ nextに次のURLが格納されている
# https://developer.atlassian.com/cloud/bitbucket/rest/api-group-repositories/#api-repositories-get
def get_repository_slugs(url:)
  res = get_bitbucket(url: url)

  repository_slugs = res["values"].map{|repo| repo['slug']}
  if res["next"]
    repository_slugs += get_repository_slugs(url: res["next"])
  end

  return repository_slugs
end

PullRequest = Struct.new(:repo, :author, :date)

# プルリクエスト一覧を取得する
def get_pullrequests(url:)
  res = get_bitbucket(url: url)

  p url
  sleep(2)

  pull_requests = res["values"].map{|pr|
    PullRequest.new(
      pr["destination"]["repository"]["name"],
      pr["author"]["nickname"],
      Time.parse(pr["created_on"]).to_date
    )
  }
  if res["next"]
    pull_requests += get_pullrequests(url: res["next"])
  end

  return pull_requests
end

# まずレポジトリ名一覧を取得
repository_slugs = get_repository_slugs(url: "https://api.bitbucket.org/2.0/repositories/#{ENV['workspace']}")

# それぞれプルリクエストを取得
pull_requests = []

# マージ済みPR一覧をとってくる
repository_slugs.map{|repo|
  pull_requests += get_pullrequests(url: "https://api.bitbucket.org/2.0/repositories/#{ENV['workspace']}/#{repo}/pullrequests?state=MERGED")
}

CSV.open("tmp/output#{Time.now.strftime("%Y%M%d_%H%m%S")}.csv","w"){|line|
  pull_requests.map{|pr|
    line << pr.values
  }
}