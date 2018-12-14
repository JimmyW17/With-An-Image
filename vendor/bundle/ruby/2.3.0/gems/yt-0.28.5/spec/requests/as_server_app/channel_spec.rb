require 'spec_helper'
require 'yt/models/channel'

describe Yt::Channel, :server_app do
  subject(:channel) { Yt::Channel.new attrs }

  context 'given an existing channel ID' do
    let(:attrs) { {id: 'UCxO1tY8h1AhOz0T4ENwmpow'} }

    it 'returns valid snippet data' do
      expect(channel.snippet).to be_a Yt::Snippet
      expect(channel.title).to be_a String
      expect(channel.description).to be_a Yt::Description
      expect(channel.thumbnail_url).to be_a String
      expect(channel.published_at).to be_a Time
    end

    it { expect(channel.status).to be_a Yt::Status }
    it { expect(channel.statistics_set).to be_a Yt::StatisticsSet }
    it { expect(channel.videos).to be_a Yt::Collections::Videos }
    it { expect(channel.videos.first).to be_a Yt::Video }
    it { expect(channel.playlists).to be_a Yt::Collections::Playlists }
    it { expect(channel.playlists.first).to be_a Yt::Playlist }
    it { expect(channel.related_playlists).to be_a Yt::Collections::Playlists }
    it { expect(channel.related_playlists.first).to be_a Yt::Playlist }

    specify 'with a public list of subscriptions' do
      expect(channel.subscribed_channels.first).to be_a Yt::Channel
    end

    context 'with a hidden list of subscriptions' do
      let(:attrs) { {id: 'UCG0hw7n_v0sr8MXgb6oel6w'} }
      it { expect{channel.subscribed_channels.size}.to raise_error Yt::Errors::Forbidden }
    end
  end

  context 'given an existing channel URL' do
    let(:attrs) { {url: 'youtube.com/fullscreen'} }

    specify 'provides access to its data' do
      expect(channel.id).to eq 'UCxO1tY8h1AhOz0T4ENwmpow'
      expect(channel.title).to eq 'Fullscreen'
      expect(channel.privacy_status).to eq 'public'
    end
  end

  context 'given an unknown channel ID' do
    let(:attrs) { {id: 'not-a-channel-id'} }

    it { expect{channel.snippet}.to raise_error Yt::Errors::NoItems }
    it { expect{channel.status}.to raise_error Yt::Errors::NoItems }
    it { expect{channel.statistics_set}.to raise_error Yt::Errors::NoItems }

    describe 'starting with UC' do
      let(:attrs) { {id: 'UC-not-a-channel-id'} }

      # NOTE: This test is just a reflection of YouTube irrational behavior of
      # returns 0 results if the name of an unknown channel starts with UC, but
      # returning 100,000 results otherwise (ignoring the channel filter).
      it { expect(channel.videos.count).to be_zero }
      it { expect(channel.videos.size).to be_zero }
    end
  end

  context 'given an unknown channel URL' do
    let(:attrs) { {url: 'youtube.com/--not-a-valid-url--'} }

    specify 'accessing its data raises an error' do
      expect{channel.id}.to raise_error Yt::Errors::NoItems
      expect{channel.title}.to raise_error Yt::Errors::NoItems
      expect{channel.status}.to raise_error Yt::Errors::NoItems
    end
  end
end