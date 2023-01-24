class ArticlesController < ApplicationController
  before_action :set_article, only: %i[ edit update publish ]
  before_action :auth, except: %i[ index show ]

  def index
    @articles = Rails.configuration.event_store
                     .read
                     .of_type(Events::Articles::Published)
                     .to_a
                     .map(&:data)
  end

  def show
    article = Article.find(params[:id])

    if @user.present?
      @article = {
        id: article.id,
        title: article.title,
        body: article.body
      }
    else
      published = Rails.configuration.event_store
                      .read
                      .backward
                      .stream(stream_name(article))
                      .of_type(Events::Articles::Published)
                      .to_a
                      .first

      if published.present?
        @article = {
          id: published.data[:article_id],
          title: published.data[:title],
          body: published.data[:body]
        }
      else
        @article = {
          id: nil,
          title: nil,
          body: nil
        }
      end
    end



    @drafts = Rails.configuration.event_store
                   .read
                   .backward
                   .stream(stream_name(article))
                   .of_type(Events::Articles::Drafted)
                   .to_a

    @drafts.map! do |draft|
      {
        author: User.find(draft.data[:user_id]).name,
        title: draft.data[:title],
        body: draft.data[:body],
        drafted_at: draft.metadata[:timestamp]
      }
    end

    @article[:contributors] = @drafts.map { |d| d[:author] }.uniq.join(', ')
  end

  def publish
    event = Events::Articles::Published.new(data: { article_id: @article.id, user_id: @user.id,
                                                    title: @article.title, body: @article.body })

    Rails.configuration.event_store.publish(event, stream_name: stream_name(@article))

    redirect_to article_path(@article, user: @user), notice: 'Article published'
  end

  def new
    @article = Article.new
  end

  def edit
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      publish_draft_event

      redirect_to article_url(@article), notice: "Article drafted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @article.update(article_params)
      publish_draft_event

      redirect_to article_url(@article), notice: "Article was drafted."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def auth
    redirect_to articles_path, alert: 'Modifying articles is only available to authors and editors' unless @user.present?
  end

    # Only allow a list of trusted parameters through.
  def article_params
    params.require(:article).permit(:title, :body)
  end

  def publish_draft_event
    event = Events::Articles::Drafted.new(data: { article_id: @article.id, user_id: @user.id,
                                                  title: article_params[:title], body: article_params[:body] })

    Rails.configuration.event_store.publish(event, stream_name: stream_name(@article))
  end
end
