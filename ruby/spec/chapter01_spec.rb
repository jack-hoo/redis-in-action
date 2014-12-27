require 'spec_helper'
require './chapter01'

describe 'chapter01' do
  let(:client) { Redis.new }

  before do
    client.flushall
  end

  describe 'article' do
    it 'is available to be posted, voted, ..' do
      article_id = post_article(client, 'username', 'A title', 'http://www.google.com')
      puts "We posted a new article with id: #{article_id}"
      expect(article_id).to be_truthy

      puts "Its HASH looks like:"
      article = client.hgetall("article:#{article_id}")
      puts article
      expect(hash).to be_truthy

      article_vote(client, 'other_user', "article:#{article_id}")
      votes = client.hget("article:#{article_id}", 'votes').to_i
      puts "We voted for the article, it now has votes: #{votes}"
      expect(votes > 1).to be_truthy
    end
  end

  describe 'post_article' do
    let(:user) { 'username' }
    let(:title) { 'A title' }
    let(:link) { 'http://www.google.com' }

    it 'returns new article id' do
      expect(post_article(client, user, title, link)).to eq 1
    end

    it 'creates article with 5 attributes' do
      expect {
        post_article(client, user, title, link)
      }.to change { client.hlen('article:1') }.by(5)
    end

    it 'adds ZSET having score key' do
      post_article(client, user, title, link)
      expect(client.zscore('score:', 'article:1').to_s).to match /\d+\.0/
    end

    it 'adds ZSET having time key' do
      post_article(client, user, title, link)
      expect(client.zscore('time:', 'article:1').to_s).to match /\d+\.0/
    end
  end
end
